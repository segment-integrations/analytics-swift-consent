//
//  Manager.swift
//  
//
//  Created by Brandon Sneed on 8/29/23.
//

import Foundation
import Segment
import Sovran

public class ConsentManager: EventPlugin {
    public let type: PluginType = .before
    public var analytics: Analytics? = nil
    public let store = Store()
    
    internal var provider: ConsentCategoryProvider
    internal var queuedEvents = [RawEvent]()
    internal let consentChange: (() -> Void)?
    @Atomic internal var started: Bool = false
        
    public init(provider: ConsentCategoryProvider, consentChanged: (() -> Void)? = nil) {
        self.provider = provider
        self.consentChange = consentChanged
        
        self.provider.setChangeCallback(notifyConsentChanged)
    }
    
    public func configure(analytics: Analytics) {
        self.analytics = analytics
        store.provide(state: ConsentState.defaultState())
    }
    
    public func update(settings: Settings, type: UpdateType) {
        let state = consentStateFrom(integrations: settings.integrations)
        store.dispatch(action: ConsentState.UpdateDestinationCategoriesAction(destinationCategories: state))
        store.dispatch(action: ConsentState.UpdateUnmappedDestinationsAction(hasUnmappedDestinations: hasUnmappedDestinations(settings)))
        store.dispatch(action: ConsentState.UpdateEnabledAtSegmentAction(enabledAtSegment: enabledAtSegment(settings)))
        
        if let analytics {
            // Add customer blocker to segment.io
            if let destination = analytics.find(key: Constants.segmentIOKey) {
                let existingBlocker = destination.analytics?.find(pluginType: SegmentConsentBlocker.self)
                if existingBlocker == nil {
                    _ = destination.add(plugin: SegmentConsentBlocker(store: store))
                }
            }
            
            // Add blocker to other destinations
            let destinationKeys = state.keys
            for key in destinationKeys {
                if let destination = analytics.find(key: key) {
                    let existingBlocker = destination.analytics?.find(pluginType: ConsentBlocker.self)
                    if existingBlocker == nil {
                        _ = destination.add(plugin: ConsentBlocker(destinationKey: key, store: store))
                    }
                }
            }
        }
    }
    
    public func execute<T: RawEvent>(event: T?) -> T? {
        if started {
            return stamp(event: event)
        }
        
        // if we haven't started, queue the events and hold.
        if let event {
            queuedEvents.append(event)
        }
        return nil
    }
}

extension ConsentManager {
    public func notifyConsentChanged() {
        analytics?.track(name: Constants.eventSegmentConsentPreference)
        if let consentChange {
            consentChange()
        }
    }
    
    public func start() {
        started = true
        // replay events.  they'll be sent back through the system and get stamped above.
        for event in queuedEvents {
            analytics?.process(event: event)
        }
        // clear the cached queue.
        queuedEvents.removeAll()
    }
}

extension ConsentManager {
    internal func consentStateFrom(integrations: JSON?) -> [String: [String]] {
        var state = [String: [String]]()
        
        integrations?.dictionaryValue?.forEach({ (key: String, value: Any) in
            guard let integrationSettings = value as? [String: Any] else { return }
            guard let consentSettings = integrationSettings[Constants.consentSettingsKey] as? [String: Any] else { return }
            guard let categoriesData = consentSettings[Constants.categoriesKey] as? [String] else { return }
                    
            var categories = [String]()
            categoriesData.forEach { categoryName in
                let normalizedName = categoryName.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespaces)
                categories.append(normalizedName)
            }
            
            state[key] = categories
        })
        
        return state
    }
    
    internal func stamp<T: RawEvent>(event: T?) -> T? {
        guard var newEvent = event else { return event }
        let consentProvider = self.provider
        
        var context: [String: Any] = event?.context?.dictionaryValue ?? [String: Any]()
        
        let categories = consentProvider.categories
        
        var preferences = [String: [String: Bool]]()
        preferences[Constants.categoryPreferenceKey] = categories
        context[Constants.consentKey] = preferences
        newEvent.context = try? JSON(context)
        
        return newEvent
    }
    
    internal func hasUnmappedDestinations(_ settings: Settings) -> Bool {
        var result = false
        if let integrations = settings.integrations?.dictionaryValue {
            result = !integrations.allSatisfy { (key: String, value: Any) in
                guard key != Constants.segmentIOKey else { return true }
                if let value = value as? [String: Any] {
                    if let categories = value[keyPath: KeyPath("\(Constants.consentSettingsKey).\(Constants.categoriesKey)")] as? [String] {
                        if categories.count > 0 {
                            return true
                        }
                    }
                }
                return false
            }
        }
        return result
    }
    
    internal func enabledAtSegment(_ settings: Settings) -> Bool {
        return settings.consentSettings != nil
    }
}

extension Analytics {
    public func notifyConsentChanged() {
        if let consentManager = find(pluginType: ConsentManager.self) {
            consentManager.notifyConsentChanged()
        }
    }
}






















//
//  Blocker.swift
//  
//
//  Created by Brandon Sneed on 9/11/23.
//

import Foundation
import Segment
import Sovran

public class ConsentBlocker: EventPlugin {
    internal let destinationKey: String
    internal let store: Store
    
    public var type: PluginType = .before
    public var analytics: Segment.Analytics?
    
    public init(destinationKey: String, store: Store) {
        self.destinationKey = destinationKey
        self.store = store
    }
    
    public func configure(analytics: Analytics) {
        self.analytics = analytics
        self.analytics?.log(message: "Consent Blocker added to \(destinationKey).")
    }
    
    public func execute<T: RawEvent>(event: T?) -> T? {
        var result = event
        guard enabledAtSegment() else { return result }
        guard let consentState: ConsentState = store.currentState() else { return nil }
        guard let requiredCategories = consentState.destinationCategories[destinationKey] else { return nil }
        
        let consented = consentCategoriesFrom(event: event)
        
        for requiredCategory in requiredCategories {
            if !consented.contains(requiredCategory) {
                if let type = event?.type {
                    analytics?.log(message: "Blocked `\(type)` from \(destinationKey).")
                }
                result = nil
                break
            }
        }
        
        return result
    }
}

extension ConsentBlocker {
    internal func consentCategoriesFrom<T: RawEvent>(event: T?) -> [String] {
        var consent = [String]()
        
        guard let context = event?.context?.dictionaryValue else { return consent }
        guard let consentSettings = context[Constants.consentKey] as? [String: [String: Bool]] else { return consent }
        guard let preferences = consentSettings[Constants.categoryPreferenceKey] else { return consent }
        
        preferences.forEach { (key: String, value: Bool) in
            if value {
                consent.append(key)
            }
        }
        
        return consent
    }
    
    internal func enabledAtSegment() -> Bool {
        if let consentState: ConsentState = store.currentState() {
            return consentState.enabledAtSegment
        }
        return true
    }
}


public class SegmentConsentBlocker: ConsentBlocker {
    internal let allowSegmentPreferenceEvent: Bool
    
    init(store: Store, allowSegmentPreferenceEvent: Bool = true) {
        self.allowSegmentPreferenceEvent = allowSegmentPreferenceEvent
        super.init(destinationKey: Constants.segmentIOKey, store: store)
    }
    
    public override func execute<T: RawEvent>(event: T?) -> T? {
        var result = event
        
        guard enabledAtSegment() else { return result }
        
        if allowSegmentPreferenceEvent, let track = event as? TrackEvent, track.event == Constants.eventSegmentConsentPreference {
            // if it's the consent pref event, it needs to go to segment
            result = event
        } else if hasUnmappedDestinations() {
            // there's an unmapped destination somewhere (device OR cloud), so it needs to go to segment, even if
            // all consent was blocked.
            result = event
        } else if allConsentBlocked(event: event) {
            // if all consent IS blocked, it does NOT to go to segment.
            result = nil
        }
        // if allConsent is not blocked, result = event (already set), carry on.
        
        if result == nil {
            if let type = event?.type {
                analytics?.log(message: "Blocked `\(type)` from \(destinationKey).")
            }
        }
        
        return result
    }
    
    internal func allConsentBlocked<T: RawEvent>(event: T?) -> Bool {
        var result = false
        
        guard let context = event?.context?.dictionaryValue else { return result }
        guard let consentSettings = context[Constants.consentKey] as? [String: [String: Bool]] else { return result }
        guard let preferences = consentSettings[Constants.categoryPreferenceKey] else { return result }

        let consent = preferences.map { (key, value) in
            return value
        }
        result = consent.allSatisfy { value in
            value == false
        }
        
        return result
    }
    
    internal func hasUnmappedDestinations() -> Bool {
        if let consentState: ConsentState = store.currentState() {
            return consentState.hasUnmappedDestinations
        }
        return true
    }
}

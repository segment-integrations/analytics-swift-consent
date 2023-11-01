//
//  TestUtilities.swift
//  
//
//  Created by Brandon Sneed on 9/11/23.
//

import Foundation
import XCTest
@testable import SegmentConsent
@testable import Segment

class DummyDestination: DestinationPlugin {
    var key: String
    var timeline: Segment.Timeline = Timeline()
    var type: Segment.PluginType = .destination
    var analytics: Segment.Analytics?
    
    init(key: String) {
        self.key = key
    }
    
    func update(settings: Settings, type: UpdateType) {
        if settings.integrationSettings(forKey: key) != nil {
            print("Update called on \(key), settings present.")
        } else {
            print("Update called on \(key), settings NOT FOUND!")
        }
    }
    
    func execute<T>(event: T?) -> T? where T : RawEvent {
        var result: T? = nil
        
        if let event, isDestinationEnabled(event: event) {
            print("Event sent to \(key).")
            // apply .before and .enrichment types first ...
            let beforeResult = timeline.applyPlugins(type: .before, event: event)
            let enrichmentResult = timeline.applyPlugins(type: .enrichment, event: beforeResult)
            
            if enrichmentResult == nil {
                print("Event blocked at \(key)")
            }
            
            // now we execute any overrides we may have made.  basically, the idea is to take an
            // incoming event, like identify, and map it to whatever is appropriate for this destination.
            var destinationResult: T? = nil
            switch enrichmentResult {
                case let e as IdentifyEvent:
                    destinationResult = identify(event: e) as? T
                case let e as TrackEvent:
                    destinationResult = track(event: e) as? T
                case let e as ScreenEvent:
                    destinationResult = screen(event: e) as? T
                case let e as GroupEvent:
                    destinationResult = group(event: e) as? T
                case let e as AliasEvent:
                    destinationResult = alias(event: e) as? T
                default:
                    break
            }
            
            // apply .after plugins ...
            result = timeline.applyPlugins(type: .after, event: destinationResult)
        }
        
        return result

    }
}

class RemoveConsentStampPlugin: Plugin {
    let type: PluginType
    var analytics: Analytics?
    
    init() {
        self.type = .enrichment
    }
    
    func execute<T>(event: T?) -> T? where T : RawEvent {
        var newEvent = event
        newEvent?.context = try? event?.context?.remove(key: Constants.consentKey)
        return newEvent
    }
}

class OutputReaderPlugin: Plugin {
    let type: PluginType
    var analytics: Analytics?
    
    var events = [RawEvent]()
    var lastEvent: RawEvent? = nil
    
    init() {
        self.type = .after
    }
    
    func execute<T>(event: T?) -> T? where T : RawEvent {
        lastEvent = event
        if let t = lastEvent as? TrackEvent {
            events.append(t)
            print("EVENT: \(t.event)")
        }
        return event
    }
}

func removeUserDefaults(forWriteKey writeKey: String) {
    UserDefaults.standard.removePersistentDomain(forName: "com.segment.storage.\(writeKey)")
    UserDefaults.standard.synchronize()
}

func waitUntilStarted(analytics: Analytics?) {
    guard let analytics = analytics else { return }
    // wait until the startup queue has emptied it's events.
    if let startupQueue = analytics.find(pluginType: StartupQueue.self) {
        while startupQueue.running != true {
            RunLoop.main.run(until: Date.distantPast)
        }
    }
}

extension XCTestCase {
    func checkIfLeaked(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            if instance != nil {
                print("Instance \(String(describing: instance)) is not nil")
            }
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak!", file: file, line: line)
        }
    }
}

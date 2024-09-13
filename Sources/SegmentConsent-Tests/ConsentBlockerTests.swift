//
//  ConsentBlockerTests.swift
//  
//
//  Created by Brandon Sneed on 9/11/23.
//

import Foundation
import XCTest
import Sovran
@testable import Segment
@testable import SegmentConsent

final class ConsentBlockerTests: XCTestCase {
    override func setUp() {
        
    }
    
    func testBlockWhenPartialConsentAvailable() {
        let analytics = Analytics(configuration: Configuration(writeKey: "cbt.testBlockWhenPartialConsentAvailable").trackApplicationLifecycleEvents(false))
        
        // Artificially give segment.io destination some consent settings
        let segmentSettings = [
            "Segment.io": [
                "consentSettings": [
                    "categories": ["cat1", "cat2"]
                ]
            ]
        ]
        let system: System? = analytics.store.currentState()
        var settings = system?.settings
        settings?.integrations = try! JSON(segmentSettings)
        analytics.store.dispatch(action: System.UpdateSettingsAction(settings: settings!))
        
        let segment = analytics.find(key: "Segment.io")
        let output = OutputReaderPlugin()
        
        let consentManager = ConsentManager(provider: SomeConsentProvider())
        analytics.add(plugin: consentManager)
        
        _ = segment?.add(plugin: ConsentBlocker(destinationKey: "Segment.io", store: consentManager.store))
        _ = segment?.add(plugin: output)

        waitUntilStarted(analytics: analytics)
        
        analytics.track(name: "stamp event")
        
        let event = output.lastEvent
        
        XCTAssertNil(event)
    }
    
    func testBlockBecauseNoConsentSettings() {
        let analytics = Analytics(configuration: Configuration(writeKey: "cbt.testBlockBecauseNoConsentSettings").trackApplicationLifecycleEvents(false))
        let output = OutputReaderPlugin()
        let consentManager = ConsentManager(provider: NoConsentProvider())
        
        // Segment destination has no consent settings, so events should get blocked.
        let segment = analytics.find(key: "Segment.io")
        
        analytics.add(plugin: consentManager)
        
        _ = segment?.add(plugin: ConsentBlocker(destinationKey: "Segment.io", store: consentManager.store))
        _ = segment?.add(plugin: output)
        
        waitUntilStarted(analytics: analytics)
        
        analytics.track(name: "stamp event")
        
        // event got dropped...
        XCTAssertNil(output.lastEvent)
    }
    
    func testBlockBecauseNoStamp() {
        let analytics = Analytics(configuration: Configuration(writeKey: "cbt.testBlockBecauseNoStamp").trackApplicationLifecycleEvents(false))
        let output = OutputReaderPlugin()
        let consentManager = ConsentManager(provider: AllConsentProvider())
        
        // Artificially give segment.io destination some consent settings
        let segmentSettings = [
            "Segment.io": [
                "consentSettings": [
                    "categories": ["cat1", "cat2"]
                ]
            ]
        ]
        let system: System? = analytics.store.currentState()
        var settings = system?.settings
        settings?.integrations = try! JSON(segmentSettings)
        analytics.store.dispatch(action: System.UpdateSettingsAction(settings: settings!))
        
        let segment = analytics.find(key: "Segment.io")
        
        analytics.add(plugin: consentManager)
        analytics.add(plugin: RemoveConsentStampPlugin())
        
        _ = segment?.add(plugin: ConsentBlocker(destinationKey: "Segment.io", store: consentManager.store))
        _ = segment?.add(plugin: output)
        
        waitUntilStarted(analytics: analytics)
        
        analytics.track(name: "stamp event")
        
        // event got dropped...
        XCTAssertNil(output.lastEvent)
    }
    
    func testBlockBecauseNoConsent() {
        let analytics = Analytics(configuration: Configuration(writeKey: "cbt.testBlockBecauseNoConsent").trackApplicationLifecycleEvents(false))
        let output = OutputReaderPlugin()
        let consentManager = ConsentManager(provider: NoConsentProvider())
        
        // Artificially give segment.io destination some consent settings
        let segmentSettings = [
            "Segment.io": [
                "consentSettings": [
                    "categories": ["cat1", "cat2"]
                ]
            ]
        ]
        let system: System? = analytics.store.currentState()
        var settings = system?.settings
        settings?.integrations = try! JSON(segmentSettings)
        analytics.store.dispatch(action: System.UpdateSettingsAction(settings: settings!))
        
        // Segment destination has no consent settings, so events should get blocked.
        //
        let segment = analytics.find(key: "Segment.io")
        
        analytics.add(plugin: consentManager)
        
        _ = segment?.add(plugin: ConsentBlocker(destinationKey: "Segment.io", store: consentManager.store))
        _ = segment?.add(plugin: output)
        
        waitUntilStarted(analytics: analytics)
        
        analytics.track(name: "stamp event")
        
        // event got dropped...
        XCTAssertNil(output.lastEvent)
    }
}

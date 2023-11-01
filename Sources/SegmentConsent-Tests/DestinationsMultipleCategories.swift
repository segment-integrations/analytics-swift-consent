//
//  NoUnmappedDestinationsTests.swift
//  
//
//  Created by Brandon Sneed on 10/24/23.
//

import XCTest
import Segment
@testable import SegmentConsent

final class DestinationsMultipleCategoriesTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNoToAll() {
        removeUserDefaults(forWriteKey: "test")
        
        let settings = Settings.load(resource: "DestinationsMultipleCategories.json", bundle: Bundle.module)
        let analytics = Analytics(configuration: Configuration(writeKey: "test")
            .trackApplicationLifecycleEvents(false)
            .defaultSettings(settings)
        )
        
        let segmentOutput = analytics.find(key: "Segment.io")?.add(plugin: OutputReaderPlugin()) as! OutputReaderPlugin
        
        let dest1 = DummyDestination(key: "DummyDest1")
        let dest2 = DummyDestination(key: "DummyDest2")
        
        let output1 = OutputReaderPlugin()
        let output2 = OutputReaderPlugin()
        
        dest1.add(plugin: output1)
        dest2.add(plugin: output2)
        
        analytics.add(plugin: dest1)
        analytics.add(plugin: dest2)
        
        let consentProvider = DummyConsentProvider(
            c0001: false,
            c0002: false,
            c0003: false,
            c0004: false,
            c0005: false
        )
        
        let consentManager = ConsentManager(provider: consentProvider)
        analytics.add(plugin: consentManager)
        
        consentManager.start()
        
        waitUntilStarted(analytics: analytics)
        
        analytics.track(name: "stamp event")
        
        RunLoop.main.run(until: Date.distantPast)
        
        XCTAssertTrue(segmentOutput.lastEvent == nil)
        XCTAssertTrue(output1.lastEvent == nil)
        XCTAssertTrue(output2.lastEvent == nil)
    }
    
    func testYesTo1() {
        removeUserDefaults(forWriteKey: "test")
        
        let settings = Settings.load(resource: "DestinationsMultipleCategories.json", bundle: Bundle.module)
        let analytics = Analytics(configuration: Configuration(writeKey: "test")
            .trackApplicationLifecycleEvents(false)
            .defaultSettings(settings)
        )
        
        let segmentOutput = analytics.find(key: "Segment.io")?.add(plugin: OutputReaderPlugin()) as! OutputReaderPlugin
        
        let dest1 = DummyDestination(key: "DummyDest1")
        let dest2 = DummyDestination(key: "DummyDest2")
        
        let output1 = OutputReaderPlugin()
        let output2 = OutputReaderPlugin()
        
        dest1.add(plugin: output1)
        dest2.add(plugin: output2)
        
        analytics.add(plugin: dest1)
        analytics.add(plugin: dest2)
        
        let consentProvider = DummyConsentProvider(
            c0001: true,
            c0002: false,
            c0003: false,
            c0004: false,
            c0005: false
        )
        
        let consentManager = ConsentManager(provider: consentProvider)
        analytics.add(plugin: consentManager)
        
        consentManager.start()
        
        waitUntilStarted(analytics: analytics)
        
        analytics.track(name: "stamp event")
        
        RunLoop.main.run(until: Date.distantPast)
        
        XCTAssertTrue(segmentOutput.lastEvent != nil)
        XCTAssertTrue(output1.lastEvent == nil)
        XCTAssertTrue(output2.lastEvent != nil)
    }

    func testYesTo2() {
        removeUserDefaults(forWriteKey: "test")
        
        let settings = Settings.load(resource: "DestinationsMultipleCategories.json", bundle: Bundle.module)
        let analytics = Analytics(configuration: Configuration(writeKey: "test")
            .trackApplicationLifecycleEvents(false)
            .defaultSettings(settings)
        )
        
        let segmentOutput = analytics.find(key: "Segment.io")?.add(plugin: OutputReaderPlugin()) as! OutputReaderPlugin
        
        let dest1 = DummyDestination(key: "DummyDest1")
        let dest2 = DummyDestination(key: "DummyDest2")
        
        let output1 = OutputReaderPlugin()
        let output2 = OutputReaderPlugin()
        
        dest1.add(plugin: output1)
        dest2.add(plugin: output2)
        
        analytics.add(plugin: dest1)
        analytics.add(plugin: dest2)
        
        let consentProvider = DummyConsentProvider(
            c0001: false,
            c0002: true,
            c0003: false,
            c0004: false,
            c0005: false
        )
        
        let consentManager = ConsentManager(provider: consentProvider)
        analytics.add(plugin: consentManager)
        
        consentManager.start()
        
        waitUntilStarted(analytics: analytics)
        
        analytics.track(name: "stamp event")
        
        RunLoop.main.run(until: Date.distantPast)
        
        XCTAssertTrue(segmentOutput.lastEvent != nil)
        XCTAssertTrue(output1.lastEvent == nil) // C0001 and C0002 need to be met and are not.
        XCTAssertTrue(output2.lastEvent == nil)
    }
    
    func testYesToAll() {
        removeUserDefaults(forWriteKey: "test")
        
        let settings = Settings.load(resource: "DestinationsMultipleCategories.json", bundle: Bundle.module)
        let analytics = Analytics(configuration: Configuration(writeKey: "test")
            .trackApplicationLifecycleEvents(false)
            .defaultSettings(settings)
        )
        
        let segmentOutput = analytics.find(key: "Segment.io")?.add(plugin: OutputReaderPlugin()) as! OutputReaderPlugin
        
        let dest1 = DummyDestination(key: "DummyDest1")
        let dest2 = DummyDestination(key: "DummyDest2")
        
        let output1 = OutputReaderPlugin()
        let output2 = OutputReaderPlugin()
        
        dest1.add(plugin: output1)
        dest2.add(plugin: output2)
        
        analytics.add(plugin: dest1)
        analytics.add(plugin: dest2)
        
        let consentProvider = DummyConsentProvider(
            c0001: true,
            c0002: true,
            c0003: false,
            c0004: false,
            c0005: false
        )
        
        let consentManager = ConsentManager(provider: consentProvider)
        analytics.add(plugin: consentManager)
        
        consentManager.start()
        
        waitUntilStarted(analytics: analytics)
        
        analytics.track(name: "stamp event")
        
        RunLoop.main.run(until: Date.distantPast)
        
        XCTAssertTrue(segmentOutput.lastEvent != nil)
        XCTAssertTrue(output1.lastEvent != nil) // C0001 and C0002 are met.
        XCTAssertTrue(output2.lastEvent != nil) // C0001 is met
    }
}

//
//  NoUnmappedDestinationsTests.swift
//  
//
//  Created by Brandon Sneed on 10/24/23.
//

import XCTest
import Segment
@testable import SegmentConsent

final class UnmappedDestinationsTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNoToAll() {
        removeUserDefaults(forWriteKey: "test")
        
        let settings = Settings.load(resource: "UnmappedDestinations.json", bundle: Bundle.module)
        let analytics = Analytics(configuration: Configuration(writeKey: "test")
            .trackApplicationLifecycleEvents(false)
            .defaultSettings(settings)
        )
        
        let segmentOutput = analytics.find(key: "Segment.io")?.add(plugin: OutputReaderPlugin()) as! OutputReaderPlugin
        
        let dest1 = DummyDestination(key: "DummyDest1")
        let dest2 = DummyDestination(key: "DummyDest2")
        let dest3 = DummyDestination(key: "DummyDest3")
        let dest4 = DummyDestination(key: "DummyDest4")
        let dest5 = DummyDestination(key: "DummyDest5")
        
        let output1 = OutputReaderPlugin()
        let output2 = OutputReaderPlugin()
        let output3 = OutputReaderPlugin()
        let output4 = OutputReaderPlugin()
        let output5 = OutputReaderPlugin()
        
        dest1.add(plugin: output1)
        dest2.add(plugin: output2)
        dest3.add(plugin: output3)
        dest4.add(plugin: output4)
        dest5.add(plugin: output5)
        
        analytics.add(plugin: dest1)
        analytics.add(plugin: dest2)
        analytics.add(plugin: dest3)
        analytics.add(plugin: dest4)
        analytics.add(plugin: dest5)
        
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
        
        XCTAssertTrue(segmentOutput.lastEvent != nil)
        XCTAssertTrue(output1.lastEvent == nil)
        XCTAssertTrue(output2.lastEvent == nil)
        XCTAssertTrue(output3.lastEvent == nil)
        XCTAssertTrue(output4.lastEvent == nil)
        XCTAssertTrue(output5.lastEvent != nil)
    }
    
    func testYesTo1() {
        removeUserDefaults(forWriteKey: "test")
        
        let settings = Settings.load(resource: "UnmappedDestinations.json", bundle: Bundle.module)
        let analytics = Analytics(configuration: Configuration(writeKey: "test")
            .trackApplicationLifecycleEvents(false)
            .defaultSettings(settings)
        )
        
        let segmentOutput = analytics.find(key: "Segment.io")?.add(plugin: OutputReaderPlugin()) as! OutputReaderPlugin
        
        let dest1 = DummyDestination(key: "DummyDest1")
        let dest2 = DummyDestination(key: "DummyDest2")
        let dest3 = DummyDestination(key: "DummyDest3")
        let dest4 = DummyDestination(key: "DummyDest4")
        let dest5 = DummyDestination(key: "DummyDest5")
        
        let output1 = OutputReaderPlugin()
        let output2 = OutputReaderPlugin()
        let output3 = OutputReaderPlugin()
        let output4 = OutputReaderPlugin()
        let output5 = OutputReaderPlugin()
        
        dest1.add(plugin: output1)
        dest2.add(plugin: output2)
        dest3.add(plugin: output3)
        dest4.add(plugin: output4)
        dest5.add(plugin: output5)
        
        analytics.add(plugin: dest1)
        analytics.add(plugin: dest2)
        analytics.add(plugin: dest3)
        analytics.add(plugin: dest4)
        analytics.add(plugin: dest5)
        
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
        
        XCTAssertTrue(segmentOutput.lastEvent != nil) // unmapped destination present, so data flows.
        XCTAssertTrue(output1.lastEvent == nil) // C0001 and C0002 have to be enabled
        XCTAssertTrue(output2.lastEvent == nil)
        XCTAssertTrue(output3.lastEvent == nil)
        XCTAssertTrue(output4.lastEvent == nil)
        XCTAssertTrue(output5.lastEvent != nil) // unmapped destination, no data flow.
    }

    func testYesTo2() {
        removeUserDefaults(forWriteKey: "test")
        
        let settings = Settings.load(resource: "UnmappedDestinations.json", bundle: Bundle.module)
        let analytics = Analytics(configuration: Configuration(writeKey: "test")
            .trackApplicationLifecycleEvents(false)
            .defaultSettings(settings)
        )
        
        let segmentOutput = analytics.find(key: "Segment.io")?.add(plugin: OutputReaderPlugin()) as! OutputReaderPlugin
        
        let dest1 = DummyDestination(key: "DummyDest1")
        let dest2 = DummyDestination(key: "DummyDest2")
        let dest3 = DummyDestination(key: "DummyDest3")
        let dest4 = DummyDestination(key: "DummyDest4")
        let dest5 = DummyDestination(key: "DummyDest5")
        
        let output1 = OutputReaderPlugin()
        let output2 = OutputReaderPlugin()
        let output3 = OutputReaderPlugin()
        let output4 = OutputReaderPlugin()
        let output5 = OutputReaderPlugin()
        
        dest1.add(plugin: output1)
        dest2.add(plugin: output2)
        dest3.add(plugin: output3)
        dest4.add(plugin: output4)
        dest5.add(plugin: output5)
        
        analytics.add(plugin: dest1)
        analytics.add(plugin: dest2)
        analytics.add(plugin: dest3)
        analytics.add(plugin: dest4)
        analytics.add(plugin: dest5)
        
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
        
        XCTAssertTrue(segmentOutput.lastEvent != nil) // unmapped destinations present so data flows
        XCTAssertTrue(output1.lastEvent == nil) // C0001 and C0002 must be met
        XCTAssertTrue(output2.lastEvent == nil)
        XCTAssertTrue(output3.lastEvent == nil)
        XCTAssertTrue(output4.lastEvent == nil)
        XCTAssertTrue(output5.lastEvent != nil) // unmapped, so data flows
    }

    func testYesTo3() {
        removeUserDefaults(forWriteKey: "test")
        
        let settings = Settings.load(resource: "UnmappedDestinations.json", bundle: Bundle.module)
        let analytics = Analytics(configuration: Configuration(writeKey: "test")
            .trackApplicationLifecycleEvents(false)
            .defaultSettings(settings)
        )
        
        let segmentOutput = analytics.find(key: "Segment.io")?.add(plugin: OutputReaderPlugin()) as! OutputReaderPlugin
        
        let dest1 = DummyDestination(key: "DummyDest1")
        let dest2 = DummyDestination(key: "DummyDest2")
        let dest3 = DummyDestination(key: "DummyDest3")
        let dest4 = DummyDestination(key: "DummyDest4")
        let dest5 = DummyDestination(key: "DummyDest5")
        
        let output1 = OutputReaderPlugin()
        let output2 = OutputReaderPlugin()
        let output3 = OutputReaderPlugin()
        let output4 = OutputReaderPlugin()
        let output5 = OutputReaderPlugin()
        
        dest1.add(plugin: output1)
        dest2.add(plugin: output2)
        dest3.add(plugin: output3)
        dest4.add(plugin: output4)
        dest5.add(plugin: output5)
        
        analytics.add(plugin: dest1)
        analytics.add(plugin: dest2)
        analytics.add(plugin: dest3)
        analytics.add(plugin: dest4)
        analytics.add(plugin: dest5)
        
        let consentProvider = DummyConsentProvider(
            c0001: false,
            c0002: false,
            c0003: true,
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
        XCTAssertTrue(output3.lastEvent == nil)
        XCTAssertTrue(output4.lastEvent == nil)
        XCTAssertTrue(output5.lastEvent != nil)
    }

    func testYesTo4() {
        removeUserDefaults(forWriteKey: "test")
        
        let settings = Settings.load(resource: "UnmappedDestinations.json", bundle: Bundle.module)
        let analytics = Analytics(configuration: Configuration(writeKey: "test")
            .trackApplicationLifecycleEvents(false)
            .defaultSettings(settings)
        )
        
        let segmentOutput = analytics.find(key: "Segment.io")?.add(plugin: OutputReaderPlugin()) as! OutputReaderPlugin
        
        let dest1 = DummyDestination(key: "DummyDest1")
        let dest2 = DummyDestination(key: "DummyDest2")
        let dest3 = DummyDestination(key: "DummyDest3")
        let dest4 = DummyDestination(key: "DummyDest4")
        let dest5 = DummyDestination(key: "DummyDest5")
        
        let output1 = OutputReaderPlugin()
        let output2 = OutputReaderPlugin()
        let output3 = OutputReaderPlugin()
        let output4 = OutputReaderPlugin()
        let output5 = OutputReaderPlugin()
        
        dest1.add(plugin: output1)
        dest2.add(plugin: output2)
        dest3.add(plugin: output3)
        dest4.add(plugin: output4)
        dest5.add(plugin: output5)
        
        analytics.add(plugin: dest1)
        analytics.add(plugin: dest2)
        analytics.add(plugin: dest3)
        analytics.add(plugin: dest4)
        analytics.add(plugin: dest5)
        
        let consentProvider = DummyConsentProvider(
            c0001: false,
            c0002: false,
            c0003: false,
            c0004: true,
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
        XCTAssertTrue(output2.lastEvent == nil)
        XCTAssertTrue(output3.lastEvent != nil)
        XCTAssertTrue(output4.lastEvent == nil)
        XCTAssertTrue(output5.lastEvent != nil)
    }

    func testYesTo1and2() {
        removeUserDefaults(forWriteKey: "test")
        
        let settings = Settings.load(resource: "UnmappedDestinations.json", bundle: Bundle.module)
        let analytics = Analytics(configuration: Configuration(writeKey: "test")
            .trackApplicationLifecycleEvents(false)
            .defaultSettings(settings)
        )
        
        let segmentOutput = analytics.find(key: "Segment.io")?.add(plugin: OutputReaderPlugin()) as! OutputReaderPlugin
        
        let dest1 = DummyDestination(key: "DummyDest1")
        let dest2 = DummyDestination(key: "DummyDest2")
        let dest3 = DummyDestination(key: "DummyDest3")
        let dest4 = DummyDestination(key: "DummyDest4")
        let dest5 = DummyDestination(key: "DummyDest5")
        
        let output1 = OutputReaderPlugin()
        let output2 = OutputReaderPlugin()
        let output3 = OutputReaderPlugin()
        let output4 = OutputReaderPlugin()
        let output5 = OutputReaderPlugin()
        
        dest1.add(plugin: output1)
        dest2.add(plugin: output2)
        dest3.add(plugin: output3)
        dest4.add(plugin: output4)
        dest5.add(plugin: output5)
        
        analytics.add(plugin: dest1)
        analytics.add(plugin: dest2)
        analytics.add(plugin: dest3)
        analytics.add(plugin: dest4)
        analytics.add(plugin: dest5)
        
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
        XCTAssertTrue(output1.lastEvent != nil)
        XCTAssertTrue(output2.lastEvent == nil)
        XCTAssertTrue(output3.lastEvent == nil)
        XCTAssertTrue(output4.lastEvent == nil)
        XCTAssertTrue(output5.lastEvent != nil)
    }

    func testYesToAll() {
        removeUserDefaults(forWriteKey: "test")
        
        let settings = Settings.load(resource: "UnmappedDestinations.json", bundle: Bundle.module)
        let analytics = Analytics(configuration: Configuration(writeKey: "test")
            .trackApplicationLifecycleEvents(false)
            .defaultSettings(settings)
        )
        
        let segmentOutput = analytics.find(key: "Segment.io")?.add(plugin: OutputReaderPlugin()) as! OutputReaderPlugin
        
        let dest1 = DummyDestination(key: "DummyDest1")
        let dest2 = DummyDestination(key: "DummyDest2")
        let dest3 = DummyDestination(key: "DummyDest3")
        let dest4 = DummyDestination(key: "DummyDest4")
        let dest5 = DummyDestination(key: "DummyDest5")
        
        let output1 = OutputReaderPlugin()
        let output2 = OutputReaderPlugin()
        let output3 = OutputReaderPlugin()
        let output4 = OutputReaderPlugin()
        let output5 = OutputReaderPlugin()
        
        dest1.add(plugin: output1)
        dest2.add(plugin: output2)
        dest3.add(plugin: output3)
        dest4.add(plugin: output4)
        dest5.add(plugin: output5)
        
        analytics.add(plugin: dest1)
        analytics.add(plugin: dest2)
        analytics.add(plugin: dest3)
        analytics.add(plugin: dest4)
        analytics.add(plugin: dest5)
        
        let consentProvider = DummyConsentProvider(
            c0001: true,
            c0002: true,
            c0003: true,
            c0004: true,
            c0005: true
        )
        
        let consentManager = ConsentManager(provider: consentProvider)
        analytics.add(plugin: consentManager)
        
        consentManager.start()
        
        waitUntilStarted(analytics: analytics)
        
        analytics.track(name: "stamp event")
        
        RunLoop.main.run(until: Date.distantPast)
        
        XCTAssertTrue(segmentOutput.lastEvent != nil)
        XCTAssertTrue(output1.lastEvent != nil)
        XCTAssertTrue(output2.lastEvent != nil)
        XCTAssertTrue(output3.lastEvent != nil)
        XCTAssertTrue(output4.lastEvent != nil)
        XCTAssertTrue(output5.lastEvent != nil)
    }

}

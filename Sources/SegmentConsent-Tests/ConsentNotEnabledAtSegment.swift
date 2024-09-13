//
//  ConsentNotEnabledAtSegment.swift
//  
//
//  Created by Brandon Sneed on 10/26/23.
//

import XCTest
import Segment
import SegmentConsent

final class ConsentNotEnabledAtSegment: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNoToAll() {
        removeUserDefaults(forWriteKey: "testNoToAll")
        
        let settings = Settings.load(resource: "ConsentNotEnabledAtSegment.json", bundle: Bundle.module)
        let analytics = Analytics(configuration: Configuration(writeKey: "testNoToAll")
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
        XCTAssertTrue(output1.lastEvent != nil)
        XCTAssertTrue(output2.lastEvent != nil)
        XCTAssertTrue(output3.lastEvent != nil)
        XCTAssertTrue(output4.lastEvent != nil)
        XCTAssertTrue(output5.lastEvent != nil)
    }

    func testYesToSome() {
        removeUserDefaults(forWriteKey: "testYesToSome")
        
        let settings = Settings.load(resource: "ConsentNotEnabledAtSegment.json", bundle: Bundle.module)
        let analytics = Analytics(configuration: Configuration(writeKey: "testYesToSome")
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

    func testYesToAll() {
        removeUserDefaults(forWriteKey: "testYesToAll")
        
        let settings = Settings.load(resource: "ConsentNotEnabledAtSegment.json", bundle: Bundle.module)
        let analytics = Analytics(configuration: Configuration(writeKey: "testYesToAll")
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

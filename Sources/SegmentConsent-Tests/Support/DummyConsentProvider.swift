//
//  Mocks.swift
//  
//
//  Created by Brandon Sneed on 9/11/23.
//

import Foundation
import Segment
@testable import SegmentConsent

class DummyConsentProvider: ConsentCategoryProvider {
    var changeCallback: SegmentConsent.ConsentChangeCallback? = nil
    
    var c0001: Bool
    var c0002: Bool
    var c0003: Bool
    var c0004: Bool
    var c0005: Bool
    
    var categories: [String : Bool] {
        return [
            "C0001": c0001,
            "C0002": c0002,
            "C0003": c0003,
            "C0004": c0004,
            "C0005": c0005,
        ]
    }
    
    init(c0001: Bool, c0002: Bool, c0003: Bool, c0004: Bool, c0005: Bool) {
        self.c0001 = c0001
        self.c0002 = c0002
        self.c0003 = c0003
        self.c0004 = c0004
        self.c0005 = c0005
    }
}


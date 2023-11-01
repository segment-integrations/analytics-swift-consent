//
//  File.swift
//  
//
//  Created by Brandon Sneed on 10/24/23.
//

import Foundation
import Segment
@testable import SegmentConsent

class AllConsentProvider: ConsentCategoryProvider {
    var changeCallback: SegmentConsent.ConsentChangeCallback? = nil
    
    var categories: [String : Bool] {
        return ["cat1": true, "cat2": true]
    }
}

class SomeConsentProvider: ConsentCategoryProvider {
    var changeCallback: SegmentConsent.ConsentChangeCallback? = nil
    
    var categories: [String : Bool] {
        return ["cat1": true, "cat2": false]
    }
}

class NoConsentProvider: ConsentCategoryProvider {
    var changeCallback: SegmentConsent.ConsentChangeCallback? = nil
    
    var categories: [String : Bool] {
        return ["cat1": false, "cat2": false]
    }
}

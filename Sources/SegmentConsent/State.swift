//
//  State.swift
//  
//
//  Created by Brandon Sneed on 8/29/23.
//

import Foundation
import Sovran
import Segment

internal typealias ConsentCategories = [String: [String]]

internal struct ConsentState: State {
    let destinationCategories: ConsentCategories
    let hasUnmappedDestinations: Bool
    let enabledAtSegment: Bool
    
    struct UpdateDestinationCategoriesAction: Action {
        let destinationCategories: ConsentCategories
        
        func reduce(state: ConsentState) -> ConsentState {
            let result = ConsentState(destinationCategories: destinationCategories, hasUnmappedDestinations: state.hasUnmappedDestinations, enabledAtSegment: state.enabledAtSegment)
            return result
        }
    }
    
    struct UpdateUnmappedDestinationsAction: Action {
        let hasUnmappedDestinations: Bool
        
        func reduce(state: ConsentState) -> ConsentState {
            let result = ConsentState(destinationCategories: state.destinationCategories, hasUnmappedDestinations: hasUnmappedDestinations, enabledAtSegment: state.enabledAtSegment)
            return result
        }
    }
    
    struct UpdateEnabledAtSegmentAction: Action {
        let enabledAtSegment: Bool
        
        func reduce(state: ConsentState) -> ConsentState {
            let result = ConsentState(destinationCategories: state.destinationCategories, hasUnmappedDestinations: state.hasUnmappedDestinations, enabledAtSegment: enabledAtSegment)
            return result
        }
    }
    
    static func defaultState() -> ConsentState {
        return ConsentState(destinationCategories: [:], hasUnmappedDestinations: false, enabledAtSegment: false)
    }
}

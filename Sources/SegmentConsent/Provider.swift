//
//  Provider.swift
//  
//
//  Created by Brandon Sneed on 8/29/23.
//

import Foundation

public typealias ConsentChangeCallback = () -> Void

public protocol ConsentCategoryProvider {
    var changeCallback: ConsentChangeCallback? { get set }
    var categories: [String: Bool] { get }
}

extension ConsentCategoryProvider {
    mutating func setChangeCallback(_ callback: @escaping ConsentChangeCallback) {
        changeCallback = callback
    }
}

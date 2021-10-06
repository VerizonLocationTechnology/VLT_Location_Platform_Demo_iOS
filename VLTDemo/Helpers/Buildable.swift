//
//  Buildable.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import Foundation

/// Buildable protocol allow easy object instantiation/creation using 'class'.build { $0.property = something }
protocol Buildable: AnyObject {}
extension Buildable {
    /// Allow propertied initialization using the build protocol
    @discardableResult
    func build(_ transform: (Self) -> Void) -> Self {
        transform(self)
        return self
    }
}

/// Allow NSObject to conform to the Buildable protocol
extension NSObject: Buildable {}

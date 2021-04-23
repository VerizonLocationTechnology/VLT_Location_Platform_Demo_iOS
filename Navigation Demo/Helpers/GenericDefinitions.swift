//
// GenericDefinitions.swift
//
// Created by Verizon Location Technology
// Copyright © 2021 Verizon Location Technology
//

import CoreLocation
import Foundation

// MARK: - Closures
/// A closure that takes in a CLLocation
typealias CLLocationClosure = (CLLocation) -> Void
/// A closure that takes in an optional error
typealias ErrorClosure = (Error?) -> Void
/// A basic closure with no inputs or outputs
typealias VoidClosure = () -> Void

// MARK: - Structures
/// Struct to report proecessing errors
struct GenericError: Error {
    /// Title describing the error
    var title: String?
    /// Relative error code for the error that has occurred
    var code: UInt32
}

//
// Storyboarded.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import UIKit

/// Coordinator pattern requires homogenous instantiation of storyboards because well, it just does.
protocol Storyboarded {
    /// Instantiate a new object from a storyboard with a given name
    static func instantiate(fromStoryboardNamed storyboardName: String) -> Self
}

/// Extension for UIView controllers that adhere to the Storyboarded protocol
extension Storyboarded where Self: UIViewController {
    /// Instantes a new UIViewController subclass using from the given Storyboard
    static func instantiate(fromStoryboardNamed storyboardName: String) -> Self {
        // Fetch the name of the UIViewController subclass
        let id = String(describing: self)
        // Fetch the storyboard with the given name
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        // Instantiate and return the newly-instantiated UIViewController subclass
        return storyboard.instantiateViewController(withIdentifier: id) as! Self // swiftlint:disable:this force_cast
    }
}

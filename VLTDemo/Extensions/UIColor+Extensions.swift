//
//  UIColor+Extensions.swift
//  VLTDemo
//
//  Created by Verizon Location Technology.
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit

extension UIColor {
    /// Returns a color with random Red, Green, Blue, and Alpha values
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: .random(in: 0.25...1))
    }
}

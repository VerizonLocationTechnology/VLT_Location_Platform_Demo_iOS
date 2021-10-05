//
// UIColor+Extensions.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import UIKit

extension UIColor {
    /// Returns a color with random Red, Green, Blue, and Alpha values
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: .random(in: 0.25...1))
    }

    /// Convert a given hex string with red, green, and blue facets into a UIColor.
    /// - Parameters:
    ///   - hexString: String in the #RRGGBB hex code format
    /// - Returns: UIColor depicting the given Hex Code String
    static func fromHex(string: String) -> UIColor {
        var colorString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        colorString = colorString.replacingOccurrences(of: "#", with: "").uppercased()

        let alpha: CGFloat = 1.0
        let red: CGFloat = colorComponentFromColor(string: colorString, start: 0, length: 2)
        let green: CGFloat = colorComponentFromColor(string: colorString, start: 2, length: 2)
        let blue: CGFloat = colorComponentFromColor(string: colorString, start: 4, length: 2)

        if red == green && green == blue {
            return UIColor(white: red, alpha: alpha)
        } else {
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }

    /// Get the specific color value depicted at the index and range of a given string
    /// - Parameters:
    ///   - colorString: The string containing the color code to be interpreted
    ///   - start: The index of the first character in the string that will depict the color code
    ///   - length: The number of characters in length that the color code consists of
    /// - Returns: CGFloat fraction of 255 that the color code depicts
    private static func colorComponentFromColor(string: String, start: Int, length: Int) -> CGFloat {
        let startIndex = string.index(string.startIndex, offsetBy: start)
        let endIndex = string.index(startIndex, offsetBy: length)
        let subString = string[startIndex..<endIndex]
        let fullHexString = length == 2 ? subString : "\(subString)\(subString)"
        var hexComponent: UInt64 = 0

        guard Scanner(string: String(fullHexString)).scanHexInt64(&hexComponent) else {
            return 0
        }
        let hexFloat = CGFloat(hexComponent)
        let floatValue = CGFloat(hexFloat / 255.0)
        return floatValue
    }
}

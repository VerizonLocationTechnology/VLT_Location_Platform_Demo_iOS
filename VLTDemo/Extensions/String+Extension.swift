//
//  String+Extension.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//
import Foundation

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}

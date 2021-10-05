//
// Data+Extensions.swift
//
// Created by Verizon Location Technology
// Copyright © 2021 Verizon Location Technology
//

import Foundation

extension Data {
    static func from(fileNamed fileName: String, withExtension fileExtension: String) -> Data? {
        if let path = Bundle.main.path(forResource: fileName, ofType: fileExtension) {
            return try? Data(contentsOf: URL(fileURLWithPath: path))
        }
        return nil
    }
}

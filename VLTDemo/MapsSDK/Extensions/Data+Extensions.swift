//
//  Data+Extensions.swift
//  VLTMapsDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
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

//
// HERE_TransportMode+Extensions.swift
//
// Created by Verizon Location Technology
// Copyright © 2021 Verizon Location Technology
//

import heresdk

extension TransportMode {
    var title: String {
        switch self {
        case .car:
            return "Car"
        case .pedestrian:
            return "Pedestrian Travel"
        case .truck:
            return "Truck"
        case .scooter:
            return "Scooter"
        case .publicTransit:
            return "Public Transit"
        @unknown default:
            DemoError(file: #file, function: "TransportMode.title", line: #line, message: "Unknown TransportMode case").print()
            return "Unknown"
        }
    }
}

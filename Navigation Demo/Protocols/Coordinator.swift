//
// Coordinator.swift
//
// Created by Verizon Location Technology.
// Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit

/// Contract that drives a coordinator pattern.
protocol Coordinator {
    /// Controller that will contain the views for the defined Coordinator
    var navigationController: UINavigationController { get set }
    /// Initiate the experience driven by the defined coordinator
    func start()
}

//
// ExitableViewDelegate.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import UIKit

/// Default interactions when view is shown in the coordinator pattern. Coordinator will handle happens to the view when its time to stop showing the view.
protocol ExitableViewDelegate: AnyObject {
    /// Exit the current view
    func exitView()
}

//
// ModeOfTravelDelegate.swift
//
// Created by Verizon Location Technology
// Copyright © 2021 Verizon Location Technology
//

import heresdk

/// Notification contract for the mode of travel changes
protocol ModeOfTravelDelegate: AnyObject {
    /// Notify the delegate that the route type has been updated
    /// - Parameter routeType: The mode of travel for a route (car, walk/bike, truck, etc.)
    func updated(routeType: TransportMode)
}

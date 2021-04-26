//
// DirectionsCell.swift
//
// Created by Verizon Location Technology.
// Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit

/// Cell for displaying route directions to the user
class DirectionsCell: UITableViewCell {
    /// Standard Reuse Identifier for this cell, matching the identifier in the storyboard
    static let reuseIdentifier = "directionCell"
    /// Image depicting the type of the direction being displayed (left, right, continue, etc.)
    @IBOutlet weak var indicatorImage: UIImageView!
    /// Description of the direction being displayed
    @IBOutlet weak var contentLabel: UILabel!
}

//
// LocationShortcutCell.swift
// VLTMaps SDK
//
// Created by Verizon Location Technology
// Copyright © 2021 Verizon Location Technology
//

import UIKit

/// Enum describing the types of shortcut cell that can be displayed
enum LocationShortcutCellType {
    case currentLocation

    /// The name of the shortcut being displayed
    var name: String {
        switch self {
        case .currentLocation:
            return "Current Location"
        }
    }

    /// Image corresponding to the type of shortcut being displayed
    var image: UIImage? {
        switch self {
        case .currentLocation:
            return UIImage(systemName: "location.circle.fill")
        }
    }
}

/// A cell for displaying shortcut locations that are readily available or saved
class LocationShortcutCell: XibTableViewCell {
    /// A consistent reuse identifier for this cell
    static let ReuseIdentifier = String(describing: self)

    /// Image view depicting the type of shortcut that this cell displays
    @IBOutlet private weak var shortcutImageView: UIImageView!
    /// Name or address corresponding to the shortcut
    @IBOutlet private weak var contentLabel: UILabel!

    /// Updates the cell to reflect the type of shortcut being displayed
    /// - Parameters:
    ///   - cellType: The type of shortcut that the cell is displaying
    func update(cellType: LocationShortcutCellType) {
        contentLabel.text = cellType.name
        shortcutImageView.image = cellType.image
    }
}

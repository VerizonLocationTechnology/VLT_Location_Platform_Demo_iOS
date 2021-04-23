//
// SearchResultCell.swift
// VLTMaps SDK
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import UIKit

/// Cell for displaying a single result from a location search
class SearchResultCell: XibTableViewCell {
    /// A consistent reuse identifier for this cell
    static let ReuseIdentifier = String(describing: SearchResultCell.self)

    /// Label displaying the distance from the starting location
    @IBOutlet private weak var distanceLabel: UILabel!
    /// Label displaying the name of the search result
    @IBOutlet private weak var nameLabel: UILabel!
    /// Label displaying the address of the search result
    @IBOutlet private weak var addressLabel: UILabel!
    /// 'Magnifying Glass' image for general search term-recommendations returned as a result
    @IBOutlet private weak var searchImageView: UIImageView!
    /// Containing stack view for the content of the cell
    @IBOutlet private weak var horizontalStackView: UIStackView!

    /// Updates the cell layout based on the destination that is passed in
    /// - Parameters:
    ///   - withDestination: The search result that will be displayed in this cell
    func update(withDestination destination: VLTLocation, imperialMeasure: Bool) {
        let distance = destination.distanceFromSearchPoint ?? 0
        distanceLabel.text = Int32(distance).formatMetersAsLengthDisplay(imperialMeasure: imperialMeasure) // nobody likes things found after the decimal, am I right?
        distanceLabel.isHidden = distance == 0
        searchImageView.isHidden = distance != 0
        horizontalStackView.alignment = distance == 0 ? .center : .top

        nameLabel.text = destination.name

        addressLabel.text = destination.address
        addressLabel.isHidden = destination.address == nil
    }
}

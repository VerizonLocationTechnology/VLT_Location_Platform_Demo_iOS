//
//  VLTHomeTableViewCell.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit

/// Table view cell for the list of functionality and features
class VLTHomeTableViewCell: UITableViewCell {

    // MARK: - Private Member
    private typealias literals = VLTLiterals.AssetNameLiterals

    // MARK: - Public Member
    static let reuseIdentifier = String(describing: VLTHomeTableViewCell.self)
    static let nibName = reuseIdentifier

    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var cardView: UIView!

    // MARK: - Functions

    /// Swap primary and secondary color on cell
    /// - Parameters:
    ///   - shouldInvert:  True: Swamp primary and secondary colors | False: Leave colors alone
    func invertColors(_ shouldInvert: Bool) {
        let primaryColor = UIColor(named: literals.primaryColor)
        let secondaryColor = UIColor(named: literals.secondaryColor)

        let background = shouldInvert ? secondaryColor : primaryColor
        let accent = shouldInvert ? primaryColor : secondaryColor

        cardView.backgroundColor = background
        titleLabel.textColor = accent
        contentLabel.textColor = accent
        arrowImage.tintColor = accent
    }
}

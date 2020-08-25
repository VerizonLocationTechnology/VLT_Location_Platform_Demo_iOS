//
//  ShapeOptionsViewController.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit

/// View Controller allowing the user to select the currently visible features to be displayed on the map
class VisibleFeaturesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Private Members
    // Cell reuse identifier
    private let reuseIdentifier = VLTLiterals.VisibleFeaturesVCLiterals.cellReuseIdentifier
    private var availableFeatures: [MapFeature] = []

    // MARK: - Public Members
    // Delegate set on calling view controller
    weak var delegate: VisibleFeaturesControllerDelegate?
    var featureVisibility = MapFeatureVisiblity() {
        didSet {
            if availableFeatures.isEmpty {
                var features: [MapFeature] = []
                for feature in MapFeature.allCases where (featureVisibility[feature] != nil) {
                    features.append(feature)
                }
                availableFeatures = features
            }
        }
    }

    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Page life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = VLTLiterals.VisibleFeaturesVCLiterals.title
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Select the options defined in the featureVisibility array.
        var index = 0
        availableFeatures.forEach({
            if featureVisibility[$0] ?? false {
                tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
            }
            index += 1
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pass back selection changes
        delegate?.updateFeatures(featureVisibility)
    }
}

// MARK: - UITableViewDataSource
extension VisibleFeaturesViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableFeatures.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create and return cell depicting an available visible feature
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let data = availableFeatures[indexPath.row]
        cell.textLabel?.text = data.title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension VisibleFeaturesViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feature = availableFeatures[indexPath.row]
        featureVisibility[feature] = true
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let feature = availableFeatures[indexPath.row]
        featureVisibility[feature] = false
    }
}

//
//  ShapeOptionsViewController.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit

/// View Controller allowing the user to select the currently visible features to be displayed on the map
class VisibleFeaturesViewController: UIViewController {
    // MARK: - Private Members
    // Cell reuse identifier
    private let reuseIdentifier = VLTLiterals.VisibleFeaturesVCLiterals.cellReuseIdentifier
    
    // MARK: - Public Members
    // Delegate set on calling view controller
    var delegate: VisibleFeaturesControllerDelegate?
    var featureVisibility = MapFeature.initialFeatureVisiblity
    
    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Page life cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set title for view controller
        self.title = VLTLiterals.VisibleFeaturesVCLiterals.title
        
        // Select the options defined in the featureVisibility array.
        for (index, feature) in MapFeature.allCases.enumerated() where (featureVisibility[feature] ?? false) {
            tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pass back selection changes
        delegate?.updateFeatures(featureVisibility)
    }
}

// MARK: - UITableViewDataSource
extension VisibleFeaturesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MapFeature.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create and return cell depicting an available visible featurE
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let data = MapFeature.allCases[indexPath.row]
        cell.textLabel?.text = data.title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension VisibleFeaturesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feature = MapFeature.allCases[indexPath.row]
        featureVisibility[feature] = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let feature = MapFeature.allCases[indexPath.row]
        featureVisibility[feature] = false
    }
}


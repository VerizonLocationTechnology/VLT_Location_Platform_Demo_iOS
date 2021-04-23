//
// RelativePositioningTableVC.swift
// VLTMaps SDK
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import UIKit

class RelativePositioningTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: Private Members
    private typealias VCLiterals = VLTLiterals.RelativePositioningVCLiterals

    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: Internal Members
    var layers: [RelativePositioningViewController.LayerNames] = []
    weak var delegate: RelativePositioningTableDelegate?

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = VCLiterals.title
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isEditing = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        delegate?.update(with: layers)
        super.viewWillDisappear(animated)
    }
}

// MARK: UITableViewDelegate Conformance
extension RelativePositioningTableVC {
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedLayer = layers[sourceIndexPath.row]
        layers.remove(at: sourceIndexPath.row)
        layers.insert(movedLayer, at: destinationIndexPath.row)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

// MARK: UITableViewDataSource Conformance
extension RelativePositioningTableVC {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return layers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        cell.textLabel?.text = layers[indexPath.row].rawValue
        return cell
    }
}

// MARK: RelativePositioningTableDelegate Declaration
protocol RelativePositioningTableDelegate: AnyObject {
    func update(with layers: [RelativePositioningViewController.LayerNames])
}

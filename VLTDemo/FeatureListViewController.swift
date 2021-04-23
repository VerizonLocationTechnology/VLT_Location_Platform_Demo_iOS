//
//  FeatureListViewController.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit

/// View controller to drive the functionality and features list
class FeatureListViewController: UIViewController {
    // MARK: - Public members
    let demoFeatures = DemoFeature.allCases

    // MARK: - Private members
    var navigationCoordinator: NavigationCoordinator?

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Page life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set title of view controller
        self.title = VLTLiterals.FeatureListVCLiterals.title

        // Register custom cell
        let customCell = UINib(nibName: VLTHomeTableViewCell.nibName, bundle: nil)
        tableView.register(customCell, forCellReuseIdentifier: VLTHomeTableViewCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Debugging fast track to specific screen when testing
        // performSegue(withIdentifier: DemoFeature.shapes.segueTitle, sender: self)
        // startNavigationDemo()
    }

     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case VLTLiterals.DemoFeatureLiterals.listenersSegue:
            /// ShapeViewController can run in two modes
            if let destination = segue.destination as? ShapesViewController {
                destination.runListeners = true
            }
        default:()
        }
    }

    /// Small method to fire up the Navigation Demo.
    private func startNavigationDemo() {
        if let navigationController = self.navigationController {
            let coordinator = NavigationCoordinator(navigationController: navigationController)
            self.navigationCoordinator = coordinator
            self.navigationCoordinator?.start()
        }
    }
}

// MARK: - UITableViewDataSource
extension FeatureListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoFeatures.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let customCell = tableView.dequeueReusableCell(withIdentifier: VLTHomeTableViewCell.reuseIdentifier, for: indexPath) as? VLTHomeTableViewCell else { return UITableViewCell() }

        let row = indexPath.row
        let data = demoFeatures[row]

        customCell.invertColors(indexPath.row == 0)
        customCell.arrowImage.isHidden = row == 0
        customCell.titleLabel.text = data.title
        customCell.contentLabel.text = data.content
        return customCell
    }
}

// MARK: - UITableViewDelegate
extension FeatureListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let segueTitle = demoFeatures[indexPath.row].segueTitle {
            performSegue(withIdentifier: segueTitle, sender: self)
        } else {
            startNavigationDemo()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

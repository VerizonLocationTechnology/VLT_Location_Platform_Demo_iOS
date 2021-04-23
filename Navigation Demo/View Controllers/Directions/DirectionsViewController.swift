//
// DirectionsViewController.swift
//
// Created by Verizon Location Technology.
// Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import heresdk
import UIKit

/// View controller for displaying navigation directions to the user in a list format
class DirectionsViewController: UIViewController,
                                Storyboarded,         // Allows for quick instantiation of DirectionsViewController
                                UITableViewDelegate,
                                UITableViewDataSource {
    // MARK: - Private variables

    /// Delegate that this controller will report to for key user-interactions
    private weak var delegate: (NavigationCoordinatorDelegate & ExitableViewDelegate)?
    /// The current route that will be displayed
    private var route: Route?
    /// Indicator of whether or not navigation is already taking place
    private var isNavigating = false
    /// Indicator of whether or not the view is disapearing due to a forward or backward navigation (back button vs map or navigation buttons)
    private var navigatingForward = false
    /// Define the units of measure to be displayed
    private var unitSystem = globalUnitSystem
    /// Canned boolean to know if the UnitSystem is imperal
    private var imperialMeasure: Bool { return unitSystem == UnitSystem.imperial }

    // MARK: - IBOutlets

    /// Label displaying the current travel time to the user
    @IBOutlet private weak var timeLabel: UILabel!
    /// Label displaying the current travel distance to the user
    @IBOutlet private weak var distanceLabel: UILabel!
    /// Label displaying route details to the user
    @IBOutlet private weak var detailsLabel: UILabel!

    /// Containing stack view for the Map button and its label
    @IBOutlet private weak var mapButtonStackView: UIStackView!
    /// Containing stack view for the Start Navigation button and its label
    @IBOutlet private weak var startNavigationButtonStackView: UIStackView!
    /// Table view displaying a list of directions to the user
    @IBOutlet weak var tableView: UITableView!

    // MARK: - View Life cycle

    /// Initialize the tableView and action buttons
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        tableView.allowsSelection = false
        tableView.reloadData()

        startNavigationButtonStackView.isHidden = isNavigating

        guard let route = route else { return }

        timeLabel.text = route.durationInSeconds.formatSecondsIntoTimeDisplay()
        distanceLabel.text = "(\(route.lengthInMeters.formatMetersAsLengthDisplay(imperialMeasure: imperialMeasure)))"
        detailsLabel.text = "By \(route.transportMode.title)"
    }

    /// React to the view disappearing by notifying the delegate of whether or not the back button was tapped
    /// - Parameters:
    ///   - animated: Indicator of whether or not the view will disappear with an animation
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if !self.navigatingForward {
            delegate?.exitView()
        }
    }

    // MARK: - IBActions
    /// React to the user tapping the 'Start Navigation' button by notifying the delegate to begin navigation
    @IBAction private func startNavigationButtonTapped() {
        navigatingForward = true
        delegate?.startNavigation()
    }

    /// React to the user tapping the 'Map' button by notifying the delegate to display the map
    @IBAction private func mapButtonTapped() {
        navigatingForward = true
        delegate?.dismissDirections()
    }

    // MARK: - Internal functions
    /// Update the acting delegate, route, and state of the view controller
    /// - Parameters:
    ///   - delegate: The delegate that this view should update as the user interacts with this view
    ///   - route: The route whose directions should be displayed to the user
    ///   - isNavigating: Indicator of whether or not the user is already navigating on the map
    func coordinateDirections(delegate: (NavigationCoordinatorDelegate & ExitableViewDelegate)?,
                              route: Route?,
                              isNavigating: Bool) {
        self.delegate = delegate
        self.route = route
        self.isNavigating = isNavigating
    }

    /// Set the UnitSystem used
    /// - Parameter unitSystem: Only two to choose from
    func updateUnitSystem(_ unitSystem: UnitSystem ) {
        self.unitSystem = unitSystem
    }
}

// MARK: - UITableViewDelegate
extension DirectionsViewController { }

// MARK: - UITableViewDatasource
extension DirectionsViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return route?.sections.count ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return route?.sections[section].maneuvers.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DirectionsCell.reuseIdentifier) as? DirectionsCell,
              let maneuver = route?.sections[indexPath.section].maneuvers[indexPath.row] else {
            return UITableViewCell()
        }

        cell.indicatorImage.image = maneuver.action.image
        cell.contentLabel.text = maneuver.text

        return cell
    }
}

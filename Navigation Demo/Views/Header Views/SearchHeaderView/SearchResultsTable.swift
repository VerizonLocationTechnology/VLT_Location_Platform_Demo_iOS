//
// SearchResultsTable.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import UIKit

/// Delegate for the SearchResultsTable to report for tap events
protocol SearchResultsTableDelegate: AnyObject {
    /// React to the current location being selected
    func currentLocationSelected()
    /// React to a destination location being selected
    func destinationSelected(_ destination: VLTLocation)
}

/// UITableView delegate controlling a tableView that will display location search results to a user
class SearchResultsTable: NSObject, UITableViewDelegate, UITableViewDataSource {
    /// Delegate that should be reported to when locations are selected on the table
    private weak var delegate: SearchResultsTableDelegate?
    /// List of search results to be displayed to the user
    private var destinations = [VLTLocation]()
    /// Indicator of whether or not the user's current location should be a selectable result
    private var showUserLocation = false
    /// UITableView that should display the location list to the user
    private weak var tableView: UITableView?
    /// Indicator of whether or not location distances should be displayed in imperial units
    private var imperialMeasure: Bool

    /// Initialize a new SearchResultsTable
    /// - Parameters:
    ///   - delegate: Delegate that should be reported to when locations are selected by the user
    ///   - tableView: TableView that should display location data to the user
    ///   - imperialMeasure: Indicator of whether or not location distances should be displayed in imperial units
    init(_ delegate: SearchResultsTableDelegate, tableView remoteTableView: UITableView, imperialMeasure: Bool ) {
        self.imperialMeasure = imperialMeasure
        super.init()
        self.tableView = remoteTableView
        self.delegate = delegate
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.ReuseIdentifier)
        tableView?.register(LocationShortcutCell.self, forCellReuseIdentifier: LocationShortcutCell.ReuseIdentifier)
        tableView?.reloadData()
        tableView?.estimatedRowHeight = 100
        tableView?.rowHeight = UITableView.automaticDimension
    }

    /// Updates the current result list displayed to the user
    /// - Parameters:
    ///   - locations: New list of search results/locations to be displayed to the user
    ///   - showUserLocation: Indicator of whether or not to display the user's current location as a search result option
    func update(locations: [VLTLocation], showUserLocation: Bool = false) {
        self.destinations = locations
        self.showUserLocation = showUserLocation
        tableView?.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension SearchResultsTable {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if showUserLocation, indexPath.section == 0 {
            delegate?.currentLocationSelected()
        } else {
            delegate?.destinationSelected(destinations[indexPath.row])
        }
    }
}

// MARK: - UITableViewDataSource
extension SearchResultsTable {
    func numberOfSections(in tableView: UITableView) -> Int {
        return showUserLocation ? 2 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showUserLocation && section == 0 {
            return 1
        }
        return destinations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showUserLocation, indexPath.section == 0 {
            guard let shortcutCell = tableView.dequeueReusableCell(withIdentifier: LocationShortcutCell.ReuseIdentifier) as? LocationShortcutCell else {
                return UITableViewCell()
            }
            shortcutCell.update(cellType: .currentLocation)
            return shortcutCell
        } else {
            guard let searchResultCell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.ReuseIdentifier) as? SearchResultCell else {
                return UITableViewCell()
            }

            searchResultCell.update(withDestination: destinations[indexPath.row], imperialMeasure: imperialMeasure)
            return searchResultCell
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(named: "MediumAccentGray")

        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.addSubview(lineView)

        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        lineView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        lineView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        lineView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true

        return containerView
    }
}

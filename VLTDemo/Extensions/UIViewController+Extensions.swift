//
// UIViewController+Extensions.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import UIKit

extension UIViewController {
    fileprivate typealias Alert = VLTLiterals.AlertLiterals

    /// Display a common Error dialog via an UIAlertController
    /// - Parameter message: Error message to display
    func showError(withMessage message: String) {
        let alert = UIAlertController(title: Alert.errorTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alert.errorActionTitle, style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

    /// Display a common Alert dialog via an UIAlertController
    /// - Parameter message: Alert message to display
    func showAlert(withMessage message: String) {
        let alert = UIAlertController(title: Alert.alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alert.alertActionTitle, style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    /// Display a common Alert dialog via an UIAlertController
    /// - Parameters:
    ///   - title: Alert title
    ///   - message: Alert message to display
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Alert.errorActionTitle, style: .default))
        present(alertController, animated: true)
    }

    /// Dismiss the current view controller based on parentage
    /// - Parameter animated: Whether to animate the navigation action
    func navigateBack(animated: Bool) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: animated)
        } else {
            self.dismiss(animated: animated, completion: nil)
        }
    }

    /// Present a modally view containing a processing indicator with message
    /// - Parameters:
    ///   - message: Message to be displayed under the spinner. Keep it simple.
    ///   - completion: When the presentation of the modal is completed the completion will be executed
    /// Note: Call dismissBlockingOverlay when blocking process is completed
    func showBlockingOverlay(withMessage message: String = "Please Wait", completion: VoidClosure? = {}) {
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 120, y: 0, width: 40, height: 40)).build {
            $0.hidesWhenStopped = true
            if traitCollection.userInterfaceStyle == .light {
                $0.style = UIActivityIndicatorView.Style.medium
            } else {
                $0.style = UIActivityIndicatorView.Style.medium
            }
            $0.startAnimating()
        }

        let alert = UIAlertController(title: nil, message: "\n" + message, preferredStyle: .alert).build {
            if traitCollection.userInterfaceStyle == .light {
                $0.view.tintColor = .black
            } else {
                $0.view.tintColor = .lightGray
            }
        }

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: completion)
    }

    /// Dismiss the modal view established by call theshowBlockingOverlay
    /// - Parameter completion: When the presentation of the modal is completely dismissed the completion will be executed
    func dismissBlockingOverlay(_ completion: (VoidClosure)? = {}) {
        self.dismiss(animated: false, completion: completion)
    }
}

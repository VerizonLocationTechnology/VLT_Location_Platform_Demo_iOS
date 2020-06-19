//
//  UIViewController+Extensions.swift
//  VLTDemo
//
//  Created by Verizon Location Technology.
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit

extension UIViewController {
    fileprivate typealias literals = VLTLiterals.AlertLiterals
    
    /// Displays an error alert to the user
    func showError(withMessage message: String) {
        let alert = UIAlertController(title: literals.errorTitle, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: literals.errorActionTitle, style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    /// Displays an alert to the user
    func showAlert(withMessage message: String) {
        let alert = UIAlertController(title: literals.alertTitle, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: literals.alertActionTitle, style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    /// Dismiss the current view controller based on parentage
    func navigateBack(animated: Bool) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: animated)
        } else {
            self.dismiss(animated: animated, completion: nil)
        }
    }
}

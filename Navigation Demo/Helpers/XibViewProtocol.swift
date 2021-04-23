//
// XibViewProtocol.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import UIKit

/// A protocol outlining how a view with a Xib file should be defined
protocol XibViewProtocol: UIView {
    /// The base UIView of the Xib
    var containerView: UIView! { get }
    /// Initializes the views that are contained in the containerView
    func initSubviews()
}

/// Methods that should be used while instantiating views from Xib files
extension XibViewProtocol where Self: UIView {
    /// Initializes the subviews of the Xib that are contained in the containerView
    func initSubviews() {
        let selfType = type(of: self)
        let nib = UINib(nibName: String(describing: selfType),
                        bundle: Bundle(for: selfType))

        nib.instantiate(withOwner: self, options: nil)
        self.addSubview(containerView)
        self.addConstraints()
    }

    /// Constrains this view to the containerView edges
    func addConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: containerView.topAnchor),
            self.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }
}

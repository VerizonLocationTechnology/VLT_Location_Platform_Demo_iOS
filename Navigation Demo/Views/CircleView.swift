//
// CircleView.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import UIKit

/// Stub protocol for views that should be shown as circles
private protocol CircleViewProtocol {}

/// Extension to house logic for making a view circular
extension CircleViewProtocol where Self: UIView {
    /// Sets the shape of the view to be a circle
    func setupView() {
        clipsToBounds = true
        layer.cornerRadius = frame.size.width / 2
    }
}

/// UIView that is guaranteed to be a circle.
class CircleView: UIView, CircleViewProtocol {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
}

/// UIButton that is guaranteed to be a circle
class CircleButton: UIButton, CircleViewProtocol {
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
}

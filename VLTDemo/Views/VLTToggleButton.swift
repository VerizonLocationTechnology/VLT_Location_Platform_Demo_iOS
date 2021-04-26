//
// VLTToggleButton.swift
// VLTMaps SDK
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import UIKit

class VLTToggleButton: UIButton {
    @IBInspectable var selectedColor: UIColor?

    @IBInspectable var unselectedColor: UIColor?

    @IBInspectable var showSelected: Bool = true {
        didSet {
            self.backgroundColor = showSelected ? selectedColor : unselectedColor
        }
    }

    func toggle() {
        showSelected.toggle()
    }
}

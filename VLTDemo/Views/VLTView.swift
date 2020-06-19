//
//  VLTRoundableView.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit

@IBDesignable
class VLTView: UIView {
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            clipsToBounds = true
            layer.cornerRadius = cornerRadius
        }
    }
}

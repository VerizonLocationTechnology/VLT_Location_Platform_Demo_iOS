//
//  VLTLabel.swift
//  VLTDemo
//
//  Created by Verizon Location Technology.
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit

@IBDesignable
class VLTLabel: UILabel {
    @IBInspectable
    var topInset: CGFloat = 0
    @IBInspectable
    var bottomInset: CGFloat = 0
    @IBInspectable
    var leftInset: CGFloat = 0
    @IBInspectable
    var rightInset: CGFloat = 0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}

//
//  VLTTextField.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit

@IBDesignable
class VLTTextField: UITextField {

    private let borderLine = CALayer()
    private let underLine = CALayer()
    private var padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    // MARK: - Border and Underline Inspectables
    @IBInspectable
    var borderColor: UIColor = .gray {
        didSet {
            borderLine.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable
    var underlineColor: UIColor = .black {
        didSet {
            underLine.borderColor = underlineColor.cgColor
        }
    }

    // MARK: - Text Padding
    @IBInspectable
    var leadingTextPadding: CGFloat = 0 {
        didSet {
            padding.left = leadingTextPadding
        }
    }

    @IBInspectable
    var trailingTextPadding: CGFloat = 0 {
        didSet {
            padding.right = trailingTextPadding
        }
    }

    @IBInspectable
    var topTextPadding: CGFloat = 0 {
        didSet {
            padding.top = topTextPadding
        }
    }

    @IBInspectable
    var bottomTextPadding: CGFloat = 0 {
        didSet {
            padding.bottom = bottomTextPadding
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {
        borderLine.borderColor = borderColor.cgColor
        underLine.borderColor = underlineColor.cgColor
        borderLine.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        borderLine.borderWidth = 1.0
        underLine.frame = CGRect(x: 0, y: frame.size.height - 1, width: frame.size.width, height: 0)
        underLine.borderWidth = 0.5

        layer.addSublayer(borderLine)
        layer.addSublayer(underLine)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        borderLine.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        borderLine.borderWidth = 1.0
        underLine.frame = CGRect(x: 0, y: frame.size.height - 1, width: frame.size.width, height: 1)
        underLine.borderWidth = 0.5
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

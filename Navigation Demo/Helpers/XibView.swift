//
// XibView.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import UIKit

/// Parent that provides default structure for a UIView class with a corresponding Xib file. Subclassing from XibView and connecting the Xib's root View object to the 'containerView' outlet described in the resultant class will allow the instantiation of a Xib-based view with a simple 'InsertViewClassNameHere()'
class XibView: UIView, XibViewProtocol {
    /// The root view for this class
    @IBOutlet var containerView: UIView!

    /// Initialize this view and its subviews
    override init(frame: CGRect) {
        super.init(frame: frame)
        /// Initialize subviews for this class
        initSubviews()
    }

    /// Initialize this view and its subviews
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        /// Initialize subviews for this class
        initSubviews()
    }
}

/// Parent UITableViewCell that provides default structure for a UITableViewCell class with a corresponding Xib file. Subclassing from a XibTableViewCell and connecting the Xib's content view object to the 'containerView' outlet described in this resultant class will allow the instantiation of a Xib-based cell with a simple 'InsertCellClassNameHere()'
class XibTableViewCell: UITableViewCell, XibViewProtocol {
    /// The content view for this cell
    @IBOutlet var containerView: UIView!

    /// Initialize this cell and its subviews
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        /// Initialize subviews for this class
        initSubviews()
    }

    /// Initialize this cell and its subviews
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        /// Initialize subviews for this class
        initSubviews()
    }
}

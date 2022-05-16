//
//  ContextMenuTitleLabel.swift
//  SwiftyContextMenu
//
//  Created by Paul Bancarel on 28/11/2020.
//

import UIKit

extension UIStackView {
    
    convenience init(arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat = 0) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.spacing = spacing
        self.axis = axis
    }

	func addBackground(color: UIColor) {
		let subView = UIView(frame: bounds)
		subView.backgroundColor = color
		subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		insertSubview(subView, at: 0)
	}

}

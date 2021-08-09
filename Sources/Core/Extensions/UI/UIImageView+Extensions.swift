//
//  UIImage+Extensions.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 22.04.2021.
//

import UIKit

extension UIImageView {
	func setTintColor(_ color: UIColor?) {
		if #available(iOS 13.0, *), let color = color {
			image?.withTintColor(color)
		} else {
			tintColor = color
		}
		setNeedsLayout()
	}
}

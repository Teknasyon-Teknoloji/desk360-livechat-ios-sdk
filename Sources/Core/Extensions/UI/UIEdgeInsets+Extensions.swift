//
//  UIEdgeInsets+Extensions.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 4.05.2021.
//

import UIKit

internal extension UIEdgeInsets {

	var vertical: CGFloat {
		return top + bottom
	}

	var horizontal: CGFloat {
		return left + right
	}

}

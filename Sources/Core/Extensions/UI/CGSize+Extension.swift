//
//  CGSize + Extension.swift
//  Example
//
//  Created by Ali Ammar Hilal on 12.04.2021.
//

import UIKit

extension CGSize {

	/// Returns width or height, whichever is the bigger value.
	var maxDimension: CGFloat {
		return max(width, height)
	}

	/// Returns width or height, whichever is the smaller value.
	var minDimension: CGFloat {
		return min(width, height)
	}
}

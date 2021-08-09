//
//  HorizontalEdgeInsets.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 13.05.2021.
//

import UIKit

/// A varient of `UIEdgeInsets` that only has horizontal inset properties
struct HorizontalEdgeInsets: Equatable {

	var left: CGFloat
	var right: CGFloat

	init(left: CGFloat, right: CGFloat) {
		self.left = left
		self.right = right
	}

	static var zero: HorizontalEdgeInsets {
		return HorizontalEdgeInsets(left: 0, right: 0)
	}
}

// MARK: Equatable Conformance
extension HorizontalEdgeInsets {

	static func == (lhs: HorizontalEdgeInsets, rhs: HorizontalEdgeInsets) -> Bool {
		return lhs.left == rhs.left && lhs.right == rhs.right
	}
}

extension HorizontalEdgeInsets {

	var horizontal: CGFloat {
		return left + right
	}
}

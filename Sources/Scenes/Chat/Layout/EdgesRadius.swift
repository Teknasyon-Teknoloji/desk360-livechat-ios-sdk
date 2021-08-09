//
//  EdgesRadius.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 14.05.2021.
//

import UIKit

struct EdgesRadius {
	let topLeft: CGFloat
	let topRight: CGFloat
	let bottomLeft: CGFloat
	let bottomRight: CGFloat
	
	init(leftSide: CGFloat, rightSide: CGFloat) {
		self.topLeft = leftSide
		self.bottomLeft = leftSide
		self.topRight = rightSide
		self.bottomRight = rightSide
	}
	
	init(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
		self.topLeft = topLeft
		self.topRight = topRight
		self.bottomLeft = bottomLeft
		self.bottomRight = bottomRight
	}
	
}

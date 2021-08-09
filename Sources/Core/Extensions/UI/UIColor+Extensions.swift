//
//  UIColor+Extensions.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 23.04.2021.
//

import UIKit

extension UIColor {
	func lighter(componentDelta: CGFloat = 0.1) -> UIColor {
		return makeColor(componentDelta: componentDelta)
	}
	
	func darker(componentDelta: CGFloat = 0.1) -> UIColor {
		return makeColor(componentDelta: -1 * componentDelta)
	}
}

private extension UIColor {
	func makeColor(componentDelta: CGFloat) -> UIColor {
		var red: CGFloat = 0
		var blue: CGFloat = 0
		var green: CGFloat = 0
		var alpha: CGFloat = 0
		
		// Extract r,g,b,a components from the
		// current UIColor
		getRed(
			&red,
			green: &green,
			blue: &blue,
			alpha: &alpha
		)
		
		// Create a new UIColor modifying each component
		// by componentDelta, making the new UIColor either
		// lighter or darker.
		return UIColor(
			red: add(componentDelta, toComponent: red),
			green: add(componentDelta, toComponent: green),
			blue: add(componentDelta, toComponent: blue),
			alpha: alpha
		)
	}
	
	// Add value to component ensuring the result is
	// between 0 and 1
	func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
		return max(0, min(1, toComponent + value))
	}
}

internal extension UIColor {

	private static func colorFromAssetBundle(named: String) -> UIColor {
		return .lightGray
	}
	
	static var incomingMessageBackground: UIColor { .red }

	static var outgoingMessageBackground: UIColor { .green }
	
	static var incomingMessageLabel: UIColor { .darkGray }
	
	static var outgoingMessageLabel: UIColor { .black }
	
	static var collectionViewBackground: UIColor { .white }

	static var typingIndicatorDot: UIColor { colorFromAssetBundle(named: "typingIndicatorDot") }
	
	static var label: UIColor { colorFromAssetBundle(named: "label") }
	
	static var avatarViewBackground: UIColor { colorFromAssetBundle(named: "avatarViewBackground") }

}

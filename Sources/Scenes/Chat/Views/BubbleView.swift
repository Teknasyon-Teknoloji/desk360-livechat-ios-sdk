//
//  BubbleView.swift
//  Example
//
//  Created by Ali Ammar Hilal on 13.05.2021.
//

import UIKit

final class BubbleView: UIView {
	
	final var direction: Direction = .none {
		didSet {
			setNeedsLayout()
		}
	}
	
	/// Lays out subviews and applys a circular mask to the layer
	override func layoutSubviews() {
		super.layoutSubviews()
		applyDirection()
	}
	
	private func applyDirection() {
		switch direction {
		case .left(let leftEdges):
			applayRadius(leftEdges)
		case .right(let rightEdges):
			applayRadius(rightEdges)
		case .none:
			break
		}
	}
	
    func applayRadius(_ edges: EdgesRadius) {
		roundCorners(topLeft: edges.topLeft, topRight: edges.topRight, bottomLeft: edges.bottomLeft, bottomRight: edges.bottomRight)
	}
	
	enum Direction {
		/// Sender messages.
		case left(edgesRaduis: EdgesRadius)
		
		/// Current user messages.
		case right(edgesRaduis: EdgesRadius)
		
		case none
	}
}

extension UIBezierPath {
	
	// swiftlint:disable function_body_length
	convenience init(
		shouldRoundRect rect: CGRect,
		topLeftRadius: CGSize = .zero,
		topRightRadius: CGSize = .zero,
		bottomLeftRadius: CGSize = .zero,
		bottomRightRadius: CGSize = .zero
	) {
		self.init()
		let path = CGMutablePath()

		let topLeft     = rect.origin
		let topRight    = CGPoint(x: rect.maxX, y: rect.minY)
		let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
		let bottomLeft  = CGPoint(x: rect.minX, y: rect.maxY)

		if topLeftRadius != .zero {
			path.move(
				to: CGPoint(
					x: topLeft.x + topLeftRadius.width,
					y: topLeft.y
				)
			)
		} else {
			path.move(
				to: CGPoint(
					x: topLeft.x,
					y: topLeft.y
				)
			)
		}

		if topRightRadius != .zero {
			path.addLine(
				to: CGPoint(
					x: topRight.x - topRightRadius.width,
					y: topRight.y
				)
			)
			path.addCurve(
				to: CGPoint(
					x: topRight.x,
					y: topRight.y + topRightRadius.height
				),
				control1: CGPoint(
						x: topRight.x,
						y: topRight.y
					),
				control2: CGPoint(
						x: topRight.x,
						y: topRight.y + topRightRadius.height
					)
			)
		} else {
			 path.addLine(
				to: CGPoint(
					x: topRight.x,
					y: topRight.y
				)
			)
		}

		if bottomRightRadius != .zero {
			path.addLine(
				to: CGPoint(
					x: bottomRight.x,
					y: bottomRight.y - bottomRightRadius.height
				)
			)
			path.addCurve(
				to: CGPoint(
					x: bottomRight.x - bottomRightRadius.width,
					y: bottomRight.y
				),
				control1: CGPoint(
					x: bottomRight.x,
					y: bottomRight.y),
				control2: CGPoint(
					x: bottomRight.x - bottomRightRadius.width,
					y: bottomRight.y
				)
			)
		} else {
			path.addLine(
				to: CGPoint(
					x: bottomRight.x,
					y: bottomRight.y
				)
			)
		}

		if bottomLeftRadius != .zero {
			path.addLine(
				to: CGPoint(
					x: bottomLeft.x + bottomLeftRadius.width,
					y: bottomLeft.y
				)
			)
			path.addCurve(
				to: CGPoint(
					x: bottomLeft.x,
					y: bottomLeft.y - bottomLeftRadius.height
				),
				control1: CGPoint(
					x: bottomLeft.x,
					y: bottomLeft.y
				),
				control2: CGPoint(
					x: bottomLeft.x,
					y: bottomLeft.y - bottomLeftRadius.height
				)
			)
		} else {
			path.addLine(
				to: CGPoint(
					x: bottomLeft.x,
					y: bottomLeft.y
				)
			)
		}

		if topLeftRadius != .zero {
			path.addLine(
				to: CGPoint(
					x: topLeft.x,
					y: topLeft.y + topLeftRadius.height
				)
			)
			path.addCurve(
				to: CGPoint(
					x: topLeft.x + topLeftRadius.width,
					y: topLeft.y
				),
				control1: CGPoint(
					x: topLeft.x,
					y: topLeft.y
				),
				control2: CGPoint(
					x: topLeft.x + topLeftRadius.width,
					y: topLeft.y
				)
			)
		} else {
			path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y))
		}

		path.closeSubpath()
		cgPath = path
	}
}

extension UIView {
	func roundCorners(
		topLeft: CGFloat 		= 0,
		topRight: CGFloat 		= 0,
		bottomLeft: CGFloat 	= 0,
		bottomRight: CGFloat 	= 0
	) {
		let topLeftRadius 		= CGSize(width: topLeft, height: topLeft)
		let topRightRadius 		= CGSize(width: topRight, height: topRight)
		let bottomLeftRadius 	= CGSize(width: bottomLeft, height: bottomLeft)
		let bottomRightRadius 	= CGSize(width: bottomRight, height: bottomRight)
		
		let maskPath = UIBezierPath(
			shouldRoundRect: bounds,
			topLeftRadius: topLeftRadius,
			topRightRadius: topRightRadius,
			bottomLeftRadius: bottomLeftRadius,
			bottomRightRadius: bottomRightRadius
		)
		let shape = CAShapeLayer()
		shape.path = maskPath.cgPath
		layer.mask = shape
	}
}
// swiftlint:enable function_body_length

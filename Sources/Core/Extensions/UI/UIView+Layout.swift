//
//  UIView+Extension.swift
//  Example
//
//  Created by Ali Ammar Hilal on 13.04.2021.
//

import UIKit

public struct AnchoredConstraints {
	public var top, leading, bottom, trailing, width, height: NSLayoutConstraint?
}

public enum Anchor {
	case top(_ top: NSLayoutYAxisAnchor, constant: CGFloat = 0)
	case leading(_ leading: NSLayoutXAxisAnchor, constant: CGFloat = 0)
	case bottom(_ bottom: NSLayoutYAxisAnchor, constant: CGFloat = 0)
	case trailing(_ trailing: NSLayoutXAxisAnchor, constant: CGFloat = 0)
	case height(_ constant: CGFloat)
	case width(_ constant: CGFloat)
}

extension UIView {
	
	func roundCorners(_ corners: UIRectCorner, radius: CGFloat, borderColor: UIColor = .clear, borderWidth: CGFloat = 0) {
		let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let mask = CAShapeLayer()
		mask.path = path.cgPath

		let borderLayer = CAShapeLayer()
		borderLayer.path = path.cgPath
		borderLayer.lineWidth = borderWidth
		borderLayer.strokeColor = borderColor.cgColor
		borderLayer.fillColor = UIColor.clear.cgColor
		borderLayer.frame = self.bounds
		self.layer.addSublayer(borderLayer)

		self.layer.mask = mask
	}
	
	@discardableResult
	func addBorders(
		edges: UIRectEdge,
		color: UIColor,
		inset: CGFloat = 0.0,
		thickness: CGFloat = 1.0) -> [UIView] {

		var borders = [UIView]()

		@discardableResult
		func addBorder(formats: String...) -> UIView {
			let border = UIView(frame: .zero)
			border.backgroundColor = color
			border.translatesAutoresizingMaskIntoConstraints = false
			self.subviews.forEach { view in
				if view.tag == 384858 + borders.count {
					view.removeFromSuperview()
				}
			}
			
			border.tag = 384858 + borders.count
			addSubview(border)
			addConstraints(formats.flatMap {
				NSLayoutConstraint.constraints(withVisualFormat: $0,
											   options: [],
											   metrics: ["inset": inset, "thickness": thickness],
											   views: ["border": border]) })
			borders.append(border)
			return border
		}
		
		if edges.contains(.top) || edges.contains(.all) {
			addBorder(formats: "V:|-0-[border(==thickness)]", "H:|-inset-[border]-inset-|")
		}

		if edges.contains(.bottom) || edges.contains(.all) {
			addBorder(formats: "V:[border(==thickness)]-0-|", "H:|-inset-[border]-inset-|")
		}

		if edges.contains(.left) || edges.contains(.all) {
			addBorder(formats: "V:|-inset-[border]-inset-|", "H:|-0-[border(==thickness)]")
		}

		if edges.contains(.right) || edges.contains(.all) {
			addBorder(formats: "V:|-inset-[border]-inset-|", "H:[border(==thickness)]-0-|")
		}

		return borders
	}
	
	func setSize(_ size: CGSize) {
		// frame.size = size
		widthAnchor.constraint(equalToConstant: size.width).isActive = true
		heightAnchor.constraint(equalToConstant: size.height).isActive = true
	}
	
	@discardableResult
	open func anchor(
		top: NSLayoutYAxisAnchor? = nil,
		leading: NSLayoutXAxisAnchor? = nil,
		bottom: NSLayoutYAxisAnchor? = nil,
		trailing: NSLayoutXAxisAnchor? = nil,
		padding: UIEdgeInsets = .zero, size: CGSize = .zero) -> AnchoredConstraints {
		
		translatesAutoresizingMaskIntoConstraints = false
		var anchoredConstraints = AnchoredConstraints()
		
		if let top = top {
			anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
		}
		
		if let leading = leading {
			anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
		}
		
		if let bottom = bottom {
			anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
		}
		
		if let trailing = trailing {
			anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
		}
		
		if size.width != 0 {
			anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
		}
		
		if size.height != 0 {
			anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
		}
		
		[anchoredConstraints.top,
		 anchoredConstraints.leading,
		 anchoredConstraints.bottom,
		 anchoredConstraints.trailing,
		 anchoredConstraints.width,
		 anchoredConstraints.height].forEach { $0?.isActive = true }
		
		return anchoredConstraints
	}
	
	@discardableResult
	open func fillSuperview(padding: UIEdgeInsets = .zero) -> AnchoredConstraints {
		translatesAutoresizingMaskIntoConstraints = false
		let anchoredConstraints = AnchoredConstraints()
		guard let superviewTopAnchor = superview?.topAnchor,
			let superviewBottomAnchor = superview?.bottomAnchor,
			let superviewLeadingAnchor = superview?.leadingAnchor,
			let superviewTrailingAnchor = superview?.trailingAnchor else {
				return anchoredConstraints
		}
		
		return anchor(top: superviewTopAnchor,
					  leading: superviewLeadingAnchor,
					  bottom: superviewBottomAnchor,
					  trailing: superviewTrailingAnchor,
					  padding: padding)
	}
	
	@discardableResult
	open func fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets = .zero) -> AnchoredConstraints {
		let anchoredConstraints = AnchoredConstraints()
		guard let superviewTopAnchor = superview?.safeAreaLayoutGuide.topAnchor,
			let superviewBottomAnchor = superview?.safeAreaLayoutGuide.bottomAnchor,
			let superviewLeadingAnchor = superview?.safeAreaLayoutGuide.leadingAnchor,
			let superviewTrailingAnchor = superview?.safeAreaLayoutGuide.trailingAnchor else {
				return anchoredConstraints
		}
		return anchor(top: superviewTopAnchor,
					  leading: superviewLeadingAnchor,
					  bottom: superviewBottomAnchor,
					  trailing: superviewTrailingAnchor,
					  padding: padding)
	}
	
	open func centerInSuperview(size: CGSize = .zero) {
		translatesAutoresizingMaskIntoConstraints = false
		if let superviewCenterXAnchor = superview?.centerXAnchor {
			centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
		}
		
		if let superviewCenterYAnchor = superview?.centerYAnchor {
			centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
		}
		
		if size.width != 0 {
			widthAnchor.constraint(equalToConstant: size.width).isActive = true
		}
		
		if size.height != 0 {
			heightAnchor.constraint(equalToConstant: size.height).isActive = true
		}
	}
	
	open func centerXTo(_ anchor: NSLayoutXAxisAnchor) {
		translatesAutoresizingMaskIntoConstraints = false
		centerXAnchor.constraint(equalTo: anchor).isActive = true
	}
	
	open func centerYTo(_ anchor: NSLayoutYAxisAnchor) {
		translatesAutoresizingMaskIntoConstraints = false
		centerYAnchor.constraint(equalTo: anchor).isActive = true
	}
	
	open func centerXToSuperview() {
		translatesAutoresizingMaskIntoConstraints = false
		if let superviewCenterXAnchor = superview?.centerXAnchor {
			centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
		}
	}
	
	open func centerYToSuperview() {
		translatesAutoresizingMaskIntoConstraints = false
		if let superviewCenterYAnchor = superview?.centerYAnchor {
			centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
		}
	}
	
	@discardableResult
	open func constrainHeight(_ constant: CGFloat) -> AnchoredConstraints {
		translatesAutoresizingMaskIntoConstraints = false
		var anchoredConstraints = AnchoredConstraints()
		anchoredConstraints.height = heightAnchor.constraint(equalToConstant: constant)
		anchoredConstraints.height?.isActive = true
		return anchoredConstraints
	}
	
	@discardableResult
	open func constrainWidth(_ constant: CGFloat) -> AnchoredConstraints {
		translatesAutoresizingMaskIntoConstraints = false
		var anchoredConstraints = AnchoredConstraints()
		anchoredConstraints.width = widthAnchor.constraint(equalToConstant: constant)
		anchoredConstraints.width?.isActive = true
		return anchoredConstraints
	}
	
	open func setupShadow(opacity: Float = 0, radius: CGFloat = 0, offset: CGSize = .zero, color: UIColor = .black) {
		layer.shadowOpacity = opacity
		layer.shadowRadius = radius
		layer.shadowOffset = offset
		layer.shadowColor = color.cgColor
	}
	
	convenience public init(backgroundColor: UIColor = .clear) {
		self.init(frame: .zero)
		self.backgroundColor = backgroundColor
	}
	
}

// MARK: - Debugging
extension UIView {
	func setDebuggingBackground(_ color: UIColor = .white) {
		#if DEBUG
		backgroundColor = color
		#endif
	}
}

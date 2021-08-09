//
//  UIView+Stacking.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 14.04.2021.
//

import UIKit

// swiftlint:disable all
public extension UIView {
	static func vStack(
		alignment: UIStackView.Alignment = .fill,
		distribution: UIStackView.Distribution = .fill,
		spacing: CGFloat = 0,
		margins: UIEdgeInsets? = nil,
		_ views: [UIView]
	) -> UIStackView {
		makeStackView(
			axis: .vertical,
			alignment: alignment,
			distribution: distribution,
			spacing: spacing,
			margins: margins,
			views
		)
	}

	static func hStack(
		alignment: UIStackView.Alignment = .fill,
		distribution: UIStackView.Distribution = .fill,
		spacing: CGFloat = 0,
		margins: UIEdgeInsets? = nil,
		_ views: [UIView]
	) -> UIStackView {
		makeStackView(
			axis: .horizontal,
			alignment: alignment,
			distribution: distribution,
			spacing: spacing,
			margins: margins,
			views
		)
	}
}

public extension UIView {
	/// Makes a fixed space along the axis of the containing stack view.
	static func spacer(length: CGFloat) -> UIView {
		Spacer(length: length, isFixed: true)
	}

	/// Makes a flexible space along the axis of the containing stack view.
	static func spacer(minLength: CGFloat = 0) -> UIView {
		Spacer(length: minLength, isFixed: false)
	}
}

// MARK: - Private
private extension UIView {
	static func makeStackView(
		axis: NSLayoutConstraint.Axis,
		alignment: UIStackView.Alignment,
		distribution: UIStackView.Distribution,
		spacing: CGFloat,
		margins: UIEdgeInsets?,
		_ views: [UIView]
	) -> UIStackView {
		let stack = UIStackView(arrangedSubviews: views)
		stack.axis = axis
		stack.alignment = alignment
		stack.distribution = distribution
		stack.spacing = spacing
		if let margins = margins {
			stack.isLayoutMarginsRelativeArrangement = true
			stack.layoutMargins = margins
		}
		return stack
	}
}

private final class Spacer: UIView {
	private let length: CGFloat
	private let isFixed: Bool
	private var axis: NSLayoutConstraint.Axis?
	private var observer: AnyObject?
	private var _constraints: [NSLayoutConstraint] = []

	init(length: CGFloat, isFixed: Bool) {
		self.length = length
		self.isFixed = isFixed
		super.init(frame: .zero)
	}

	override func willMove(toSuperview newSuperview: UIView?) {
		super.willMove(toSuperview: newSuperview)

		guard let stackView = newSuperview as? UIStackView else {
			axis = nil
			setNeedsUpdateConstraints()
			return
		}

		axis = stackView.axis
		observer = stackView.observe(\.axis, options: [.initial, .new]) { [weak self] _, axis in
			self?.axis = axis.newValue
			self?.setNeedsUpdateConstraints()
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate override func updateConstraints() {
		super.updateConstraints()

		_constraints.removeAll()

		let attributes: [NSLayoutConstraint.Attribute]
		switch axis {
		case .horizontal:
			attributes = [.width]
		case .vertical:
			attributes = [.height]
		default:
			attributes = [.height, .width] // Not really an expected use-case
		}
		_constraints = attributes.map {
			let constraint = NSLayoutConstraint(
				item: self,
				attribute: $0,
				relatedBy: isFixed ? .equal : .greaterThanOrEqual,
				toItem: nil,
				attribute: .notAnAttribute,
				multiplier: 1,
				constant: length
			)
			constraint.priority = UILayoutPriority(999)
			return constraint
		}
		NSLayoutConstraint.activate(_constraints)
	}
}

// swiftlint:disable identifier_name
extension UIEdgeInsets {
	static func all(_ value: CGFloat) -> UIEdgeInsets {
		UIEdgeInsets(top: value, left: value, bottom: value, right: value)
	}

	init(v: CGFloat, h: CGFloat) {
		self = UIEdgeInsets(top: v, left: h, bottom: v, right: h)
	}
}

private extension UIView {
	@discardableResult func border(_ color: UIColor, width: CGFloat) -> UIView {
//        layer.borderColor = color.cgColor
//        layer.borderWidth = width
		return self
	}

	func pinToSuperviewEdges() {
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			leftAnchor.constraint(equalTo: superview!.leftAnchor),
			topAnchor.constraint(equalTo: superview!.topAnchor),
			rightAnchor.constraint(equalTo: superview!.rightAnchor),
			bottomAnchor.constraint(equalTo: superview!.bottomAnchor)
		])
	}

	func centerInSuperview() {
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			centerXAnchor.constraint(equalTo: superview!.centerXAnchor),
			centerYAnchor.constraint(equalTo: superview!.centerYAnchor),
			leftAnchor.constraint(greaterThanOrEqualTo: superview!.leftAnchor),
			rightAnchor.constraint(lessThanOrEqualTo: superview!.rightAnchor)
		])
	}

	func pinSize(_ size: CGSize) {
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			widthAnchor.constraint(equalToConstant: size.width),
			heightAnchor.constraint(equalToConstant: size.height)
		])
	}
}
// swiftlint:enable all

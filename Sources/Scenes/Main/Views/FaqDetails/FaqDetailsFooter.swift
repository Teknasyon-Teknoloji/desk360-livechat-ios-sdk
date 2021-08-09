//
//  FaqDetailsFooter.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 20.04.2021.
//

import UIKit

final class FaqDetailsFooter: UIView, Layoutable {
	
	lazy var backButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Back", for: .normal)
		button.backgroundColor = .blueRibbon
		button.layer.cornerRadius = 22
		return button
	}()
	
	func setupViews() {
		addSubview(backButton)
	}
	
	func setupLayout() {
		backButton.centerInSuperview()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		backButton.setSize(.init(width: frame.width * 0.65, height: 44))
	}
}

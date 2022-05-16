//
//  CannedResponseButtonCell.swift
//  Desk360LiveChat
//
//  Created by Alper Tabak on 25.02.2022.
//

import Foundation
import UIKit

final class CannedResponseButtonCell: ChatBaseCell, CannedResponseCell {
	
	var item: ResponseElement? {
		didSet {
			self.buttonSelected = item?.isSelected ?? false
			self.updateUI()
		}
	}
	
	var latestIndex: IndexPath? {
		didSet {
            if currentIndex?.section ?? 0 > latestIndex?.section ?? 0 {
                let condition = (currentIndex?.item ?? 0 > latestIndex?.item ?? 0)
                self.contentView.isUserInteractionEnabled = condition
                self.button.isUserInteractionEnabled = condition
                return
            }
            self.button.isUserInteractionEnabled = (currentIndex?.section == latestIndex?.section)
			self.contentView.isUserInteractionEnabled = (currentIndex?.section == latestIndex?.section)
		}
	}
	var currentIndex: IndexPath?
	var tapHandler: ((ResponseElement) -> Void)?
	
	private var buttonSelected: Bool = false {
		didSet {
			if buttonSelected {
				self.button.layer.borderColor = UIColor(hex: "#1f71ea")?.cgColor
				self.button.layer.borderWidth = 2
				self.button.backgroundColor = UIColor(hex: "f4f9ff")
				self.button.setTitleColor(UIColor(hex: "#1f71ea"), for: .normal)
			}
		}
	}
	
	lazy var button: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("", for: .normal)
		button.setTitleColor(UIColor(hex: "#0a1546"), for: .normal)
		button.titleLabel?.font = FontFamily.Gotham.medium.font(size: 14)
		button.titleLabel?.textAlignment = .center
		button.backgroundColor = UIColor(hex: "f4f9ff")
		button.layer.cornerRadius = 8
        button.isExclusiveTouch = true
        button.isMultipleTouchEnabled = false
		return button
	}()
	
	override func setupViews() {
		super.setupViews()
		contentView.addSubview(button)
		button.addTarget(self, action: #selector(handleButtonTap), for: .touchDown)
        contentView.isMultipleTouchEnabled = false
        contentView.isExclusiveTouch = true
		setupLayout()
	}
	
	private func setupLayout() {
		button.anchor(
			top: self.topAnchor,
			leading: self.leadingAnchor,
			bottom: self.bottomAnchor,
			trailing: self.trailingAnchor,
			padding: .zero
		)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		self.button.backgroundColor = UIColor(hex: "f4f9ff")
		self.button.layer.borderWidth = 0
		self.button.setTitleColor(UIColor(hex: "#0a1546"), for: .normal)
        if self.latestIndex == nil {
            self.contentView.isUserInteractionEnabled = true
        }
		self.latestIndex = nil
		self.currentIndex = nil
        self.layoutIfNeeded()
	}
	
	private func updateUI() {
		guard let item = item else { return }
		UIView.performWithoutAnimation {
			self.button.setTitle("\(item.content)", for: .normal)
			self.button.layoutIfNeeded()
		}
	}
	
    
	@objc private func handleButtonTap() {
		guard let item = item else { return }
        self.button.isUserInteractionEnabled = false
		self.buttonSelected = true
		self.tapHandler?(item)
	}
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layoutIfNeeded()
    }
	
}

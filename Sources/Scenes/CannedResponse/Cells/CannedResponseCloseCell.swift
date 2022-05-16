//
//  CannedResponseCloseCell.swift
//  Desk360LiveChat
//
//  Created by Alper Tabak on 25.02.2022.
//

import Foundation
import UIKit

final class CannedResponseCloseCell: ChatBaseCell {
	
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
				self.HStack.layer.borderColor = UIColor(hex: "#1f71ea")?.cgColor
				self.HStack.layer.borderWidth = 2
				self.HStack.backgroundColor = UIColor(hex: "f4f9ff")
				self.titleLabel.textColor = UIColor(hex: "#1f71ea")
			}
		}
	}
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = UIColor(hex: "#0a1546")
		label.font = FontFamily.Gotham.medium.font(size: 14)
		return label
	}()
	
	private lazy var imageView: UIImageView = {
		let image = Images.cannedResponseReturnHome
		let imageView = UIImageView(image: image)
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	private lazy var HStack: UIStackView = {
		let stackView = UIStackView(
			arrangedSubviews: [titleLabel, imageView],
			axis: .horizontal,
			spacing: 4
		)
		stackView.distribution = .fillProportionally
		stackView.alignment = .fill
		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.layoutMargins = .init(v: 0, h: 12)
		return stackView
	}()
	
	private(set) lazy var button: UIButton = {
		let button = UIButton(type: .system)
		button.backgroundColor = .clear
		button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
		return button 
	}()
	
	override func setupViews() {
		super.setupViews()
		contentView.addSubview(HStack)
		contentView.addSubview(button)
		HStack.backgroundColor = UIColor(hex: "f4f9ff")
		HStack.addBackground(color: UIColor(hex: "f4f9ff") ?? .clear)
		HStack.layer.cornerRadius = 8
		setupLayout()
	}
	
	private func setupLayout() {
		HStack.anchor(
			top: self.topAnchor,
			leading: self.leadingAnchor,
			bottom: self.bottomAnchor,
			trailing: self.trailingAnchor,
			padding: .zero
		)
		button.fillSuperview()
		imageView.anchor(size: .init(width: 20, height: 20))
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		self.HStack.backgroundColor = UIColor(hex: "f4f9ff")
		self.HStack.layer.borderWidth = 0
		self.titleLabel.textColor = UIColor(hex: "#0a1546")
	}
	
	private func updateUI() {
		guard let item = item else { return }
		self.titleLabel.text = item.content
		var image: UIImage?
		
		switch item.actionableType {
		case .closeAndSurvey:
			image = Images.cannedResponseSurveyIcon
		case .liveHelp:
			image = Images.cannedResponseChatIcon
		case .returnStartPath:
			image = Images.cannedResponseReturnHome
		default:
			break
		}
		
		guard let image = image else { return }
		self.imageView.image = image
		
	}
	
	@objc private func handleButtonTap() {
		guard let item = item else { return }
		self.buttonSelected = true
		self.tapHandler?(item)
	}
	
}

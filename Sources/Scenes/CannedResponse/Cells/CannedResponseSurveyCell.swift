//
//  CannedResponseSurveyCell.swift
//  Desk360LiveChat
//
//  Created by Alper Tabak on 1.03.2022.
//

import Foundation
import UIKit

final class CannedResponseSurveyCell: ChatBaseCell {
	
	var tapHandler: ((CannedResponseSurveyType) -> Void)?
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.text = Strings.canned_response_feedback_title
		label.textColor = UIColor(hex: "2a2c4b")
		label.font = FontFamily.Gotham.medium.font(size: 16)
		return label
	}()
	
	private lazy var descriptionLabel: UILabel = {
		let label = UILabel()
		label.text = Strings.canned_response_feedback_description
		label.textColor = UIColor(hex: "2a2c4b")
		label.font = FontFamily.Gotham.light.font(size: 15)
		label.numberOfLines = 0
		return label
	}()
	
	private lazy var labelVStack: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
		stackView.alignment = .leading
		stackView.distribution = .fill
		stackView.axis = .vertical
		stackView.spacing = 2
		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.layoutMargins = .init(top: 10, left: 20, bottom: 10, right: 8)
		stackView.backgroundColor = UIColor(hex: "f0f2f6")
		stackView.clipsToBounds = true
		stackView.layer.cornerRadius = 20
		stackView.layer.maskedCorners = [.layerMaxXMinYCorner]
		return stackView
	}()
	
	private lazy var goodButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle(Strings.canned_response_feedback_button_good, for: .normal)
		button.setTitleColor(UIColor(hex: "0a1546"), for: .normal)
		button.setImage(Images.cannedResponseGoodIcon, for: .normal)
		button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 8)
		return button
	}()
	
	private lazy var badButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle(Strings.canned_response_feedback_button_bad, for: .normal)
		button.setTitleColor(UIColor(hex: "0a1546"), for: .normal)
		button.setImage(Images.cannedResponseBadIcon, for: .normal)
		button.imageEdgeInsets = .init(top: 3, left: 0, bottom: 0, right: 8)
		return button
	}()
	
	private lazy var buttonHStack: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [goodButton, badButton])
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		stackView.axis = .horizontal
		stackView.backgroundColor = UIColor(hex: "ffffff")
		stackView.layer.cornerRadius = 10
		stackView.layer.borderWidth = 1
		stackView.layer.borderColor = UIColor(hex: "e5e8ed")?.cgColor
		stackView.clipsToBounds = true
		stackView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		return stackView
	}()
	
	private lazy var VStack = UIView.vStack(
		alignment: .fill,
		distribution: .fill,
		spacing: 0,
		margins: .zero,
		[labelVStack, buttonHStack]
	)
	
	override func setupViews() {
		super.setupViews()
		contentView.addSubview(VStack)
		[goodButton, badButton].forEach({ $0.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside) })
		labelVStack.addBackground(color: UIColor(hex: "f0f2f6") ?? .clear)
		buttonHStack.addBackground(color: UIColor(hex: "ffffff") ?? .clear)
		setupLayout()
	}
	
	private func setupLayout() {
		VStack.anchor(
			top: self.contentView.topAnchor,
			leading: self.contentView.leadingAnchor,
			bottom: self.contentView.bottomAnchor,
			trailing: self.contentView.trailingAnchor,
			padding: .init(top: 0, left: 0, bottom: 0, right: 100)
		)
		buttonHStack.anchor(size: .init(width: 0, height: 48))
	}
			
	@objc private func handleButtonTap(_ button: UIButton) {
		switch button {
		case self.goodButton:
			self.tapHandler?(.good)
		case self.badButton:
			self.tapHandler?(.bad)
		default:
			break
		}
	}
	
}

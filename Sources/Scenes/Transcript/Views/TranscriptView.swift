//
//  TranscriptView.swift
//  Example
//
//  Created by Ali Ammar Hilal on 19.06.2021.
//

import UIKit

final class TranscriptView: UIView, Layoutable {
	lazy var agentView: ChatAgentView = {
		ChatAgentView.create()
	}()
	
	lazy var sucessTickView: UIImageView = {
		let imageView = UIImageView()
		imageView.setSize(.init(width: 80, height: 80))
		imageView.layer.cornerRadius = 40
		imageView.image = Images.successTick.withRenderingMode(.alwaysOriginal)
		imageView.clipsToBounds = true
		return imageView
	}()
	
	private lazy var messageTitle: UILabel = {
		let label = UILabel()
		label.font = FontFamily.Gotham.medium.font(size: 20)
		label.text = Strings.transcript_title
		label.textAlignment = .center
		return label
	}()
	
	private lazy var feedbackLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.font = FontFamily.Gotham.book.font(size: 16)
		label.text = Strings.transcript_description
		label.clipsToBounds = true
		label.textAlignment = .center
		return label
	}()
	
	lazy var backButton: UIButton = {
		let button = UIButton(type: .system)
		button.layer.cornerRadius = 22
		button.setTitle(Strings.transcript_button, for: .normal)
		button.backgroundColor = config?.general.sendButtonBackgroundColor.uiColor
		button.setTitleColor(config?.general.sendButtonTextColor.uiColor, for: .normal)
		return button
	}()
	
	lazy var closeChatButton: UIButton = {
		let button = UIButton(type: .system)
		button.layer.cornerRadius = 22
		button.setTitle(Strings.transcript_close_the_chat, for: .normal)
		button.backgroundColor = .lightGray // config?.general.sendButtonBackgroundColor.uiColor?.lighter()
		button.setTitleColor(config?.general.sendButtonTextColor.uiColor, for: .normal)
		return button
	}()
	
	lazy var textStack: UIView = .vStack(
		alignment: .center,
		distribution: .fill,
		spacing: 10,
		[
			messageTitle,
			feedbackLabel
		]
	)
	
	lazy var buttonStack: UIView = .vStack(
		alignment: .center,
		distribution: .equalCentering,
		spacing: 10,
		[
			backButton,
			closeChatButton
		]
	)
	
	func setupViews() {
		addSubview(agentView)
		addSubview(sucessTickView)
		addSubview(textStack)
		addSubview(buttonStack)
		agentView.optionsButton.isHidden = true
	}
	
	func setupLayout() {

		agentView.anchor(
			top: safeAreaLayoutGuide.topAnchor,
			leading: leadingAnchor,
			bottom: nil,
			trailing: trailingAnchor
		)
		
		sucessTickView.anchor(top: agentView.bottomAnchor, padding: .init(v: 30, h: 0))
		sucessTickView.centerXToSuperview()
		
		textStack.anchor(
			top: sucessTickView.bottomAnchor,
		    leading: leadingAnchor,
		    bottom: nil,
		    trailing: trailingAnchor,
			padding: .init(v: 20, h: 20)
		)
		
		buttonStack.anchor(
			top: textStack.bottomAnchor,
			leading: leadingAnchor,
			bottom: nil,
			trailing: trailingAnchor,
			padding: .init(v: 20, h: 20)
		)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		[backButton, closeChatButton].forEach {
			$0.widthAnchor.constraint(equalToConstant: frame.width * 0.7).isActive = true
			$0.heightAnchor.constraint(equalToConstant: 44).isActive = true
		}
	}
}

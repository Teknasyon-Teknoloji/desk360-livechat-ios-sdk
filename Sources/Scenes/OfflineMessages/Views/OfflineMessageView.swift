//
//  OfflineMessageView.swift
//  Example
//
//  Created by Ali Ammar Hilal on 17.06.2021.
//

import UIKit

final class OfflineMessageView: UIView, Layoutable, Loadingable {
	
	lazy var agentView: ChatAgentView = {
		ChatAgentView.create()
	}()
	
	private lazy var messageLogo: UIImageView = {
		let imageView = UIImageView()
		imageView.image = Images.offlineMessage.withRenderingMode(.alwaysOriginal)
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	private lazy var messageTitle: UILabel = {
		let label = UILabel()
		label.font = FontFamily.Gotham.medium.font(size: 20)
		// label.text = "Message Sent!"
		label.textAlignment = .center
		return label
	}()
	
	private lazy var feedbackLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.font = FontFamily.Gotham.book.font(size: 16)
		// label.text = "Thank you. We will contact you as soon as possible"
		label.clipsToBounds = true
		label.textAlignment = .center
		return label
	}()
	
	lazy var closeChatButton: ActionButton = {
		let button = ActionButton(type: .system)
		button.setTitle(Strings.faq_back, for: .normal)
		button.setTitleColor(config?.general.sendButtonTextColor.uiColor, for: .normal)
		// button.setImage(Images.send.withRenderingMode(.alwaysOriginal), for: .normal)
		button.backgroundColor = config?.general.sendButtonBackgroundColor.uiColor
		// button.imageEdgeInsets.left = -20
		button.layer.cornerRadius = 22
		button.titleLabel?.font = FontFamily.Gotham.medium.font(size: 14)
		return button
	}()
	
	func setupViews() {
        addSubview(agentView)
		addSubview(messageLogo)
		addSubview(messageTitle)
		addSubview(feedbackLabel)
		addSubview(closeChatButton)
		messageTitle.text = Strings.message_sent_title
		feedbackLabel.text = Strings.feedback_message
		feedbackLabel.textColor = config?.chat.messageTextColor.uiColor
		backgroundColor = config?.chat.messageBackgroundColor.uiColor
		
	}
	
	func setupLayout() {

	}
	
	override func layoutSubviews() {
        agentView.anchor(top: safeAreaLayoutGuide.topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
		messageLogo.centerXToSuperview()
		messageLogo.anchor(
			top: agentView.bottomAnchor,
			padding: .init(v: 50, h: 0),
			size: .init(width: 100, height: 100)
		)
		
		messageTitle.centerXToSuperview()
		messageTitle.anchor(
			top: messageLogo.bottomAnchor,
			padding: .init(v: 20, h: 0)
		)
		
		feedbackLabel.centerXToSuperview()
		feedbackLabel.anchor(
			top: messageTitle.bottomAnchor,
			padding: .init(v: 8, h: 0)
		)
		
		closeChatButton.centerXToSuperview()
		closeChatButton.anchor(
			top: feedbackLabel.bottomAnchor,
			padding: .init(v: 25, h: 0),
			size: .init(width: frame.width * 0.8, height: 44)
		)
		
		feedbackLabel.widthAnchor.constraint(equalToConstant: frame.width * 0.9).isActive = true
	}
}

// struct NavigationItems {
//	static func back(target: AnyObject, selector: Selector) -> UIBarButtonItem {
//		.init(image: Images.back.withRenderingMode(.alwaysOriginal), style: .plain, target: target, action: selector)
//	}
// }

//
//  SurveySizeCalculator.swift
//  Desk360LiveChat
//
//  Created by Alper Tabak on 2.03.2022.
//

import UIKit

final class SurveySizeCalculator: MessageSizeCalculator {

	var incomingMessageLabelInsets = UIEdgeInsets(top: 7, left: 18, bottom: 7, right: 14)
	var outgoingMessageLabelInsets = UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 18)
	
	var labelInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 8)
	var titleLabelFont = FontFamily.Gotham.medium.font(size: 16) ?? .preferredFont(forTextStyle: .body)
	var descriptionLabelFont = FontFamily.Gotham.light.font(size: 14) ?? .preferredFont(forTextStyle: .body)

	var messageLabelFont = FontFamily.Gotham.book.font(size: 16) ?? UIFont.preferredFont(forTextStyle: .body)

	func messageLabelInsets(for message: MessageCellViewModel) -> UIEdgeInsets {
		let isFromCurrentSender = message.isFromCurrentUser
		return isFromCurrentSender ? outgoingMessageLabelInsets : incomingMessageLabelInsets
	}

	override func messageContainerMaxWidth(for message: MessageCellViewModel) -> CGFloat {
		return UIScreen.main.bounds.size.width - 120
	}

	override func messageContainerSize(for message: MessageCellViewModel) -> CGSize {
		let maxWidth = messageContainerMaxWidth(for: message) - 50

		var messageContainerSize: CGSize
		let attributedText: NSAttributedString

		let textMessageKind = message.kind.textMessageKind
		switch textMessageKind {
		case .attributedText(let text):
			attributedText = text
		case .text(let text), .emoji(let text):
			attributedText = NSAttributedString(string: text, attributes: [.font: descriptionLabelFont])
		default:
			fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
		}

		messageContainerSize = labelSize(for: attributedText, considering: maxWidth)
		let noOfLines = Int(ceil(CGFloat(messageContainerSize.height) / descriptionLabelFont.lineHeight))
		let messageInsets = messageLabelInsets(for: message)
		var extraHeight: CGFloat =  0 // (!message.isFromCurrentUser && noOfLines >= 3) ? 10 : 4
		if noOfLines > 10 {
			extraHeight += 10
			messageContainerSize.height = attributedText.string.size(constraintedWidth: messageContainerSize.width).height
		}
		extraHeight += noOfLines > 20 ? 30 : 0
		messageContainerSize.height += messageInsets.vertical + extraHeight

		return messageContainerSize
	}

	override func configure(attributes: UICollectionViewLayoutAttributes) {
		super.configure(attributes: attributes)
		guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }

		let dataSource = messagesLayout.messagesDataSource
		let indexPath = attributes.indexPath
		let message = dataSource.messageForItem(at: indexPath)

		attributes.messageLabelInsets = messageLabelInsets(for: message)
		attributes.messageLabelFont = messageLabelFont

		switch message.kind {
		case .attributedText(let text):
			guard !text.string.isEmpty else { return }
			guard let font = text.attribute(.font, at: 0, effectiveRange: nil) as? UIFont else { return }
			attributes.messageLabelFont = font
		default:
			break
		}
	}
}

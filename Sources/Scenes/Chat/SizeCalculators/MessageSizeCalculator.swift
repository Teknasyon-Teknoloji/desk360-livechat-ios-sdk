//
//  MessageSizeCalculator.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 14.05.2021.
//

import UIKit

class MessageSizeCalculator: CellSizeCalculator {

	init(layout: MessagesCollectionViewFlowLayout? = nil) {
		super.init()
		
		self.layout = layout
	}
	
	var incomingMessagePadding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 34)
	var outgoingMessagePadding = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 4)

	var incomingMessageBottomViewAlignment = LabelAlignment(alignment: .left, textInsets: UIEdgeInsets(left: 42))
	var outgoingMessageBottomViewAlignment = LabelAlignment(alignment: .right, textInsets: UIEdgeInsets(right: 42))
	
	var messagesLayout: MessagesCollectionViewFlowLayout {
		guard let layout = layout as? MessagesCollectionViewFlowLayout else {
			fatalError("Layout object is missing or is not a MessagesCollectionViewFlowLayout")
		}
		return layout
	}

	override func configure(attributes: UICollectionViewLayoutAttributes) {
		guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }

		let dataSource = messagesLayout.messagesDataSource
		let indexPath = attributes.indexPath
		let message = dataSource.messageForItem(at: indexPath)
		attributes.messageContainerPadding = messageContainerPadding(for: message)
		attributes.messageContainerSize = messageContainerSize(for: message)
	}

	override func sizeForItem(at indexPath: IndexPath) -> CGSize {
		let dataSource = messagesLayout.messagesDataSource
		let message = dataSource.messageForItem(at: indexPath)
		let itemHeight = cellContentHeight(for: message, at: indexPath)
		return CGSize(width: messagesLayout.itemWidth, height: itemHeight)
	}

	func cellContentHeight(for message: MessageCellViewModel, at indexPath: IndexPath) -> CGFloat {

		let messageContainerHeight = messageContainerSize(for: message).height
		let messageVerticalPadding = messageContainerPadding(for: message).vertical
		var errorViewHeight: CGFloat = .zero
		if !message.isSentSuccessfully {
			errorViewHeight = 20
		}
		
		let totalLabelHeight: CGFloat = messageContainerHeight + messageVerticalPadding + errorViewHeight
		
		return totalLabelHeight // + 30.0 // for date label
	}

	// MARK: - MessageContainer
	func messageContainerPadding(for message: MessageCellViewModel) -> UIEdgeInsets {
		let isFromCurrentSender = message.isFromCurrentUser
		return isFromCurrentSender ? outgoingMessagePadding : incomingMessagePadding
	}

	func messageContainerSize(for message: MessageCellViewModel) -> CGSize {
		// Returns .zero by default
		return .zero
	}

	func messageContainerMaxWidth(for message: MessageCellViewModel) -> CGFloat {
		let messagePadding = messageContainerPadding(for: message)
		return messagesLayout.itemWidth - messagePadding.horizontal
	}

	// MARK: - Helpers
	func labelSize(for attributedText: NSAttributedString, considering maxWidth: CGFloat) -> CGSize {
		let constraintBox = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
		let rect = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin], context: nil).integral
		return rect.size
	}
    
    func countLabelLines(string: String, consideringWidth width: CGFloat) -> Int {
        guard let string = string as? NSString else { return 0 }
        let font = FontFamily.Gotham.book.font(size: 15) ?? .systemFont(ofSize: 15)
        let rect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = string.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return Int(ceil(CGFloat(labelSize.height) / font.lineHeight))
    }
}

fileprivate extension UIEdgeInsets {
	init(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) {
		self.init(top: top, left: left, bottom: bottom, right: right)
	}
}

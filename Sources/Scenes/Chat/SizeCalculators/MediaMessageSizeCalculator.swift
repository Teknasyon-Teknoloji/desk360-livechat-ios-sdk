//
//  MediaMessageSizeCalculator.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 14.05.2021.
//

import UIKit

class MediaMessageSizeCalculator: MessageSizeCalculator {
	
	override func messageContainerSize(for message: MessageCellViewModel) -> CGSize {
		let maxWidth = messageContainerMaxWidth(for: message)
        let messageLabelFont = FontFamily.Gotham.book.font(size: 15)
        let attributedText = NSAttributedString(string: message.message.content, attributes: [.font: messageLabelFont])
        let textHeight = message.message.content.isEmpty ? 10 : labelSize(for: attributedText, considering: maxWidth).height + 20
		switch message.kind {
		case .photo:
			if message.isSentSuccessfully {
				return .init(width: maxWidth - 80, height: 185 + textHeight)
			} else {
				return .init(width: maxWidth - 80, height: 44 + textHeight)
			}
		case .video:
            var uploadingIndicatorHeight: CGFloat = message.isUploading ? 20 : 0
			if message.isSentSuccessfully {
				return .init(width: maxWidth - 80, height: 175 + textHeight + uploadingIndicatorHeight)
			} else {
				return .init(width: maxWidth - 80, height: 44 + textHeight + uploadingIndicatorHeight)
			}
		default:
			return .zero
		// fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
		}
	}
}

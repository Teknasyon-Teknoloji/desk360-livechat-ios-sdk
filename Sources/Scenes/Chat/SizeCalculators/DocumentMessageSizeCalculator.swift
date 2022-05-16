//
//  .swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 10.06.2021.
//

import UIKit

class DocumentMessageSizeCalculator: MessageSizeCalculator {

	override func messageContainerSize(for message: MessageCellViewModel) -> CGSize {
		let maxWidth = messageContainerMaxWidth(for: message)
        let messageLabelFont = FontFamily.Gotham.book.font(size: 15)
        let attributedText = NSAttributedString(string: message.message.content, attributes: [.font: messageLabelFont])
        var textHeight: CGFloat = message.message.content.isEmpty ? 20 : 40
        let labelLines = countLabelLines(string: message.message.content, consideringWidth: maxWidth - 100)
        let uploadingIndicatorHeight: CGFloat = message.isUploading ? 30 : 0
        if !message.message.content.isEmpty, labelLines > 1 {
            textHeight = labelSize(for: attributedText, considering: maxWidth - 100).height + 40
			//textHeight += CGFloat((Float(labelLines) * 12)) + 10
        }
    
		switch message.kind {
		case .document(let item):
            if message.isSentSuccessfully {
                return .init(width: maxWidth - 80, height: 60 + textHeight + uploadingIndicatorHeight)
            } else {
                return .init(width: maxWidth - 80, height: 68 + textHeight + uploadingIndicatorHeight)
            }
		default:
			return .zero
		}
	}
    
}

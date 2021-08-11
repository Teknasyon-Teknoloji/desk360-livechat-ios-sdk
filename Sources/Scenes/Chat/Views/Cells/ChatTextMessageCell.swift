//
//  ChatTextMessageCell.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 14.05.2021.
//

import UIKit

class ChatTextMessageCell: ChatBaseCell {
	
	override func setupViews() {
		super.setupViews()
		bubbleView.addSubview(messageLabel)
	}
	
	override func layoutViews() {
		super.layoutViews()
		
	}
	
	override func configure(with viewModel: MessageCellViewModel) {
		super.configure(with: viewModel)
        messageLabel.isFromCurrentuser = viewModel.isFromCurrentUser
		let detectors = viewModel.messageDetectors
		messageLabel.configure {
            messageLabel.enabledDetectors = [.address, .url, .phoneNumber, .date, .hashtag]
		}
		let textMessageKind = viewModel.message.kind.textMessageKind
		switch textMessageKind {
		case .text(let text), .emoji(let text):
			messageLabel.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
			messageLabel.textColor = .black
			if let font = font(for: textMessageKind) {
				messageLabel.font = font
			}
			
		case .attributedText(let text):
			messageLabel.attributedText = text
			
		default:
			break
		}
        tickAndTimeStack.removeFromSuperview()
        messageLabel.addSubview(tickAndTimeStack)
		if viewModel.isFromCurrentUser {
//			messageLabel.frame = bubbleView.bounds.inset(by: .init(top: 0, left: 8, bottom: 0, right: 8))
            messageLabel.anchor(top: bubbleView.topAnchor, leading: bubbleView.leadingAnchor, bottom: bubbleView.bottomAnchor, trailing: bubbleView.trailingAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 8))
			messageLabel.textInsets = .init(top: 10, left: 10, bottom: 10, right: 0)
		} else {
           // messageLabel.frame = bubbleView.bounds//.inset(by: .init(top: 0, left: 8, bottom: 8, right: 0))
            messageLabel.anchor(top: bubbleView.topAnchor, leading: bubbleView.leadingAnchor, bottom: bubbleView.bottomAnchor, trailing: bubbleView.trailingAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 10))
			messageLabel.textInsets = .init(top: 10, left: 10, bottom: 10, right: 8)
		}
        
        let lineWidth = messageLabel.lastLineWidth
        bringSubviewToFront(tickAndTimeStack)
    
       // messageLabel.setDebuggingBackground(.red)
        
        if lineWidth <= bubbleView.frame.width * 0.8 && messageLabel.numberOfLines > 1 {
            tickAndTimeStack.anchor(
                top: nil,
                leading: messageLabel.trailingAnchor,
                bottom: messageLabel.bottomAnchor,
                trailing: bubbleView.trailingAnchor,
                padding: .init(top: 0, left: 8, bottom: 4, right: 4)
            )
        } else {
            let extraInset: CGFloat = viewModel.isIncomingMessage ? 4 : 0
            tickAndTimeStack.anchor(
                top: nil,
                leading: nil,
                bottom: bubbleView.bottomAnchor,
                trailing: messageLabel.trailingAnchor,
                padding: .init(top: -12, left: 8, bottom: 8, right: 4 + extraInset)
            )
        }
        
        if viewModel.isFromCurrentUser {
            bubbleView.backgroundColor = config?.general.backgroundHeaderColor.uiColor
            let color = config?.general.headerTitleColor.uiColor
            let attr: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.underlineColor: color,
                .font: FontFamily.Gotham.book.font(size: 15)
            ]
            
            messageLabel.setAttributes(attr, detector: .url)
            messageLabel.textColor = color

        } else {
            bubbleView.backgroundColor = config?.chat.messageBackgroundColor.uiColor
            let color = config?.chat.messageTextColor.uiColor
            let attr: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.underlineColor: color,
                .font: FontFamily.Gotham.book.font(size: 15)
            ]

            messageLabel.setAttributes(attr, detector: .url)
            messageLabel.textColor = color
        }
        
        messageLabel.enabledDetectors = Array(viewModel.messageDetectors)
        messageLabel.setNeedsDisplay()
	}
	
	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
		super.apply(layoutAttributes)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		messageLabel.attributedText = nil
		messageLabel.text = nil
	}
    
    override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        super.handleTapGesture(gesture)
    }
}

private extension ChatTextMessageCell {
	
	func font(for textMessageKind: MessageKind) -> UIFont? {
        guard let textFont = FontFamily.Gotham.book.font(size: 15) else { return nil }
		
		switch textMessageKind {
		case .text:
			return textFont
		case .emoji:
			return FontFamily.Gotham.book.font(size: textFont.pointSize * 2)
		default:
			return nil
		}
	}
}

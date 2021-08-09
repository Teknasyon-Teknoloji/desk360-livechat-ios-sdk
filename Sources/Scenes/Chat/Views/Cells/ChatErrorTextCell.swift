//
//  ChatErrorTextMessageCell.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 14.05.2021.
//

import UIKit

class CellErrorView: UIView {
	lazy var errorIcon: UIImageView = {
		let imageView = UIImageView()
		imageView.image = Images.alertIcon.withRenderingMode(.alwaysOriginal)
		return imageView
	}()
	
	lazy var errorLabel: UILabel = {
		let label = UILabel()
		label.textColor = .red
		label.font = FontFamily.Gotham.book.font(size: 10)
		label.text = "Message not sent"
		return label
	}()
	
	lazy var stack = UIStackView(arrangedSubviews: [errorIcon, errorLabel, .spacer()])
	
	override func layoutSubviews() {
		super.layoutSubviews()
		addSubview(stack)
		stack.distribution = .equalCentering
		stack.axis = .horizontal
		stack.fillSuperview()
	}
}

// final class ChatErrorTextMessageCell: ChatTextMessageCell {
//	
//	private lazy var errorView: CellErrorView = {
//		let view = CellErrorView()
//		return view
//	}()
//	
//	override func setupViews() {
//		super.setupViews()
//		contentView.addSubview(errorView)
//	}
//	
//	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
//		super.apply(layoutAttributes)
//		 guard let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes else { return }
//		let textWidth = CGSize.labelSize(for: "Message not Sent", font: FontFamily.Gotham.book.font(size: 10), considering: contentView.frame.width).width
//		let iconWidth: CGFloat = 30
//		let totalWidth = textWidth + iconWidth
//		var x =  bubbleView.frame.minX
//		let y = bubbleView.frame.maxY + 8
//		if attributes.isIncomingMessage {
//			x = bubbleView.frame.maxX - totalWidth
//		}
//		errorView.stack.alignment = attributes.cellBottomViewAlignment.alignment.stackViewAlignment()
//		errorView.stack.spacing = 4
//		errorView.frame.origin = .init(x: x, y: y)
//		errorView.errorLabel.textAlignment = attributes.cellBottomViewAlignment.alignment.textAlignment()
//	
//		errorView.frame.size = .init(width: textWidth + 30, height: 15)
//	}
// }
//
extension CGSize {
	static func labelSize(for string: String, font: UIFont, considering maxWidth: CGFloat) -> CGSize {
		let attributedText = NSAttributedString(string: string, attributes: [.font: font])
		let constraintBox = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
		let rect = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral
		return rect.size
	}
}

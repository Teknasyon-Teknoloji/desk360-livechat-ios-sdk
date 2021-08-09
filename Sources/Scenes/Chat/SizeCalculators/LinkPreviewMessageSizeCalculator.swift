//
//  LinkPreviewMessageSizeCalculator.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 14.05.2021.
//

import UIKit

class LinkPreviewMessageSizeCalculator: TextMessageSizeCalculator {

	static let imageViewSize: CGFloat = 60
	static let imageViewMargin: CGFloat = 8

	var titleFont: UIFont
	var teaserFont: UIFont = .preferredFont(forTextStyle: .caption2)
	var domainFont: UIFont

	override init(layout: MessagesCollectionViewFlowLayout?) {
		let titleFont = UIFont.systemFont(ofSize: 13, weight: .semibold)
		let titleFontMetrics = UIFontMetrics(forTextStyle: .footnote)
		self.titleFont = titleFontMetrics.scaledFont(for: titleFont)

		let domainFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
		let domainFontMetrics = UIFontMetrics(forTextStyle: .caption1)
		self.domainFont = domainFontMetrics.scaledFont(for: domainFont)

		super.init(layout: layout)
	}

	override func messageContainerMaxWidth(for message: MessageCellViewModel) -> CGFloat {
		switch message.kind {
		case .linkPreview:
			let maxWidth = super.messageContainerMaxWidth(for: message)
			return max(maxWidth, (layout?.collectionView?.bounds.width ?? 0) * 0.75)
		default:
			return super.messageContainerMaxWidth(for: message)
		}
	}

	override func messageContainerSize(for message: MessageCellViewModel) -> CGSize {
		guard case MessageKind.linkPreview(let linkItem) = message.kind else {
			fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
		}

		var containerSize = super.messageContainerSize(for: message)
		containerSize.width = max(containerSize.width, messageContainerMaxWidth(for: message))

		let labelInsets: UIEdgeInsets = messageLabelInsets(for: message)

		let minHeight = containerSize.height + LinkPreviewMessageSizeCalculator.imageViewSize
		let previewMaxWidth = containerSize.width - (LinkPreviewMessageSizeCalculator.imageViewSize + LinkPreviewMessageSizeCalculator.imageViewMargin + labelInsets.horizontal)

		calculateContainerSize(with: NSAttributedString(string: linkItem.title ?? "", attributes: [.font: titleFont]),
							   containerSize: &containerSize,
							   maxWidth: previewMaxWidth)

		calculateContainerSize(with: NSAttributedString(string: linkItem.teaser, attributes: [.font: teaserFont]),
							   containerSize: &containerSize,
							   maxWidth: previewMaxWidth)

		calculateContainerSize(with: NSAttributedString(string: linkItem.url.host ?? "", attributes: [.font: domainFont]),
							   containerSize: &containerSize,
							   maxWidth: previewMaxWidth)

		containerSize.height = max(minHeight, containerSize.height) + labelInsets.vertical

		return containerSize
	}

	override func configure(attributes: UICollectionViewLayoutAttributes) {
		super.configure(attributes: attributes)
		guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }
		attributes.linkPreviewFonts = LinkPreviewFonts(titleFont: titleFont, teaserFont: teaserFont, domainFont: domainFont)
	}
}

private extension LinkPreviewMessageSizeCalculator {
	private func calculateContainerSize(with attibutedString: NSAttributedString, containerSize: inout CGSize, maxWidth: CGFloat) {
		guard !attibutedString.string.isEmpty else { return }
		let size = labelSize(for: attibutedString, considering: maxWidth)
		containerSize.height += size.height
	}
}

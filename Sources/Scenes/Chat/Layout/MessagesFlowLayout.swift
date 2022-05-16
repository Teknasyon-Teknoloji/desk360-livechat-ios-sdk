//
//  MessagesFlowLayout.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 13.05.2021.
//

import UIKit

enum Alignment {
	case left
	case right
}

extension Alignment {
	func map<NewAlignment>(_ transform: (Alignment) -> NewAlignment) -> NewAlignment {
		transform(self)
	}
}

extension Alignment {
	func textAlignment() -> NSTextAlignment {
		map {
			switch $0 {
			case .left: return NSTextAlignment.left
			case .right: return NSTextAlignment.right
			}
		}
	}
	
	func stackViewAlignment() -> UIStackView.Alignment {
		map {
			switch $0 {
			case .left: return UIStackView.Alignment.leading
			case .right: return UIStackView.Alignment.trailing
			}
		}
	}
}

/// The layout attributes used by a `MessageCollectionViewCell` to layout its subviews.
class MessagesCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {

	// MARK: - Properties
	var messageContainerSize: CGSize = .zero
	var messageContainerPadding: UIEdgeInsets = .zero
	var messageLabelFont: UIFont = UIFont.preferredFont(forTextStyle: .body)
	var messageLabelInsets: UIEdgeInsets = .zero
	
	var isIncomingMessage = false
	
	var cellBottomViewAlignment = LabelAlignment(alignment: .left, textInsets: .zero)
	var cellBottomViewSize: CGSize = .zero
	var messageBottomLabelSize: CGSize = .zero
	var messageTimeLabelSize: CGSize = .zero
	var linkPreviewFonts = LinkPreviewFonts(titleFont: .preferredFont(forTextStyle: .footnote),
												   teaserFont: .preferredFont(forTextStyle: .caption2),
												   domainFont: .preferredFont(forTextStyle: .caption1))
	
	// MARK: - Helpers
	override func copy(with zone: NSZone? = nil) -> Any {
		// swiftlint:disable force_cast
		let copy = super.copy(with: zone) as! MessagesCollectionViewLayoutAttributes
		copy.messageContainerSize = messageContainerSize
		copy.messageContainerPadding = messageContainerPadding
		copy.messageLabelFont = messageLabelFont
		copy.messageLabelInsets = messageLabelInsets
		copy.cellBottomViewSize = cellBottomViewSize
		copy.messageTimeLabelSize = messageTimeLabelSize
		copy.messageBottomLabelSize = messageBottomLabelSize
		copy.isIncomingMessage = isIncomingMessage
		copy.cellBottomViewAlignment = cellBottomViewAlignment
		return copy
		// swiftlint:enable force_cast
	}

	override func isEqual(_ object: Any?) -> Bool {
		// MARK: - LEAVE this as is
		if let attributes = object as? MessagesCollectionViewLayoutAttributes {
			return super.isEqual(object)
				&& attributes.messageContainerSize == messageContainerSize
				&& attributes.messageContainerPadding == messageContainerPadding
				&& attributes.messageLabelFont == messageLabelFont
				&& attributes.messageLabelInsets == messageLabelInsets
				&& attributes.cellBottomViewAlignment == cellBottomViewAlignment
				&& attributes.cellBottomViewSize == cellBottomViewSize
				&& attributes.messageTimeLabelSize == messageTimeLabelSize
				&& attributes.messageBottomLabelSize == messageBottomLabelSize
				&& attributes.linkPreviewFonts == linkPreviewFonts
				&& attributes.isIncomingMessage == isIncomingMessage
		} else {
			return false
		}
	}
}

/// The layout object used by `MessagesCollectionView` to determine the size of all
/// framework provided `MessageBaseCell` subclasses.
class MessagesCollectionViewFlowLayout: UICollectionViewFlowLayout {

	override class var layoutAttributesClass: AnyClass {
		return MessagesCollectionViewLayoutAttributes.self
	}

	/// The `MessagesCollectionView` that owns this layout object.
	var messagesCollectionView: MessagesCollectionView {
		guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
			fatalError()
		}
		return messagesCollectionView
	}
	
	/// The `MessagesDataSource` for the layout's collection view.
	var messagesDataSource: MessagesDataSource {
		guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
			fatalError()
		}
		return messagesDataSource
	}
	
	var itemWidth: CGFloat {
		guard let collectionView = collectionView else { return 0 }
		return collectionView.frame.width - sectionInset.left - sectionInset.right
	}

	private(set) var isTypingIndicatorViewHidden: Bool = true

	// MARK: - Initializers
	override init() {
		super.init()
		setupView()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupView()
	}

	// MARK: - Methods
	private func setupView() {
		sectionInset = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
	}

	// MARK: - Typing Indicator API
	/// Notifies the layout that the typing indicator will change state
	///
	/// - Parameters:
	///   - isHidden: A Boolean value that is to be the new state of the typing indicator
	func setTypingIndicatorViewHidden(_ isHidden: Bool) {
		isTypingIndicatorViewHidden = isHidden
	}

	/// A method that by default checks if the section is the last in the
	/// `messagesCollectionView` and that `isTypingIndicatorViewHidden`
	/// is FALSE
	///
	/// - Parameter section
	/// - Returns: A Boolean indicating if the TypingIndicator should be presented at the given section
	func isSectionReservedForTypingIndicator(_ section: Int) -> Bool {
		guard let collectionView = collectionView else { return false }
		return !isTypingIndicatorViewHidden && section == collectionView.numberOfSections - 1
	}

	// MARK: - Attributes
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		guard let attributesArray = super.layoutAttributesForElements(in: rect) as? [MessagesCollectionViewLayoutAttributes] else {
			return nil
		}
		for attributes in attributesArray where attributes.representedElementCategory == .cell {
			let cellSizeCalculator = cellSizeCalculatorForItem(at: attributes.indexPath)
			let message = messagesDataSource.messageForItem(at: attributes.indexPath)
			attributes.isIncomingMessage = !message.isFromCurrentUser
			attributes.cellBottomViewAlignment.alignment = message.isFromCurrentUser ? .right : .left
			cellSizeCalculator.configure(attributes: attributes)
		}
		return attributesArray
	}

	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		guard let attributes = super.layoutAttributesForItem(at: indexPath) as? MessagesCollectionViewLayoutAttributes else {
			return nil
		}
		let message = messagesDataSource.messageForItem(at: attributes.indexPath)
		attributes.isIncomingMessage = message.isFromCurrentUser
		attributes.cellBottomViewAlignment.alignment = message.isFromCurrentUser ? .right : .left
		if attributes.representedElementCategory == .cell {
			let cellSizeCalculator = cellSizeCalculatorForItem(at: attributes.indexPath)
			cellSizeCalculator.configure(attributes: attributes)
		}
		return attributes
	}

	// MARK: - Layout Invalidation
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return collectionView?.bounds.width != newBounds.width
	}

	override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
		let context = super.invalidationContext(forBoundsChange: newBounds)
		guard let flowLayoutContext = context as? UICollectionViewFlowLayoutInvalidationContext else { return context }
		flowLayoutContext.invalidateFlowLayoutDelegateMetrics = shouldInvalidateLayout(forBoundsChange: newBounds)
		return flowLayoutContext
	}

	// MARK: - Cell Sizing
	lazy var textMessageSizeCalculator = TextMessageSizeCalculator(layout: self)
	lazy var attributedTextMessageSizeCalculator = TextMessageSizeCalculator(layout: self)
	lazy var emojiMessageSizeCalculator: TextMessageSizeCalculator = {
		let sizeCalculator = TextMessageSizeCalculator(layout: self)
		sizeCalculator.messageLabelFont = UIFont.systemFont(ofSize: sizeCalculator.messageLabelFont.pointSize * 2)
		return sizeCalculator
	}()
	
	lazy var photoMessageSizeCalculator = MediaMessageSizeCalculator(layout: self)
	lazy var videoMessageSizeCalculator = MediaMessageSizeCalculator(layout: self)
	lazy var typingIndicatorSizeCalculator = TypingCellSizeCalculator(layout: self)
	lazy var linkPreviewMessageSizeCalculator = LinkPreviewMessageSizeCalculator(layout: self)
	lazy var documentMessageSizeCalculator = DocumentMessageSizeCalculator(layout: self)
	lazy var surveySizeCalculator = SurveySizeCalculator(layout: self)

	/// Note:
	/// - If you override this method, remember to call MessageLayoutDelegate's
	/// customCellSizeCalculator(for:at:in:) method for MessageKind.custom messages, if necessary
	/// - If you are using the typing indicator be sure to return the `typingIndicatorSizeCalculator`
	/// when the section is reserved for it, indicated by `isSectionReservedForTypingIndicator`
	func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
		if isSectionReservedForTypingIndicator(indexPath.section) {
			return typingIndicatorSizeCalculator
		}
		let message = messagesDataSource.messageForItem(at: indexPath)
		
		if message.id == "-1" {
			return surveySizeCalculator
		}
		
		switch message.kind {
		case .text:
			 return textMessageSizeCalculator
		case .attributedText:
			return attributedTextMessageSizeCalculator
		case .emoji:
			return emojiMessageSizeCalculator
		case .photo:
			return photoMessageSizeCalculator
		case .video:
			return videoMessageSizeCalculator
		case .document:
			return documentMessageSizeCalculator
		case .linkPreview:
			return linkPreviewMessageSizeCalculator
		}
	}

	func typingIndicatorViewSize(at indexPath: IndexPath) -> CGSize {
		typingIndicatorSizeCalculator.sizeForItem(at: indexPath)
	}
	
	func layoutForCannedResponse(value: Bool) {
		self.textMessageSizeCalculator.cannedResponseActive = value
	}
	
	func sizeForItem(at indexPath: IndexPath) -> CGSize {
		let calculator = cellSizeCalculatorForItem(at: indexPath)
		return calculator.sizeForItem(at: indexPath)
	}
	
	/// Set `incomingMessagePadding` of all `MessageSizeCalculator`s
	func setMessageIncomingMessagePadding(_ newPadding: UIEdgeInsets) {
		messageSizeCalculators().forEach { $0.incomingMessagePadding = newPadding }
	}
	
	/// Set `outgoingMessagePadding` of all `MessageSizeCalculator`s
	func setMessageOutgoingMessagePadding(_ newPadding: UIEdgeInsets) {
		messageSizeCalculators().forEach { $0.outgoingMessagePadding = newPadding }
	}
	
	/// Set `incomingMessageBottomLabelAlignment` of all `MessageSizeCalculator`s
	func setMessageIncomingMessageBottomLabelAlignment(_ newAlignment: LabelAlignment) {
		messageSizeCalculators().forEach { $0.incomingMessageBottomViewAlignment = newAlignment }
	}
	
	/// Set `outgoingMessageBottomLabelAlignment` of all `MessageSizeCalculator`s
	func setMessageOutgoingMessageBottomLabelAlignment(_ newAlignment: LabelAlignment) {
		messageSizeCalculators().forEach { $0.outgoingMessageBottomViewAlignment = newAlignment }
	}

	/// Get all `MessageSizeCalculator`s
	func messageSizeCalculators() -> [MessageSizeCalculator] {
		return [textMessageSizeCalculator,
				attributedTextMessageSizeCalculator,
				emojiMessageSizeCalculator,
				photoMessageSizeCalculator,
				videoMessageSizeCalculator,
				linkPreviewMessageSizeCalculator,
				documentMessageSizeCalculator
		]
	}
}

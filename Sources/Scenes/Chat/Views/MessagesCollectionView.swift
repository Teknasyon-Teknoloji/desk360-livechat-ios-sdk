//
//  MessagesCollectionView.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 1.05.2021.
//

import Foundation
import UIKit

class MessagesCollectionView: UICollectionView {

	// MARK: - Properties
	weak var messagesDataSource: MessagesDataSource?
	weak var messageCellDelegate: MessageCellDelegate?

	var isTypingIndicatorHidden: Bool {
		return messagesCollectionViewFlowLayout.isTypingIndicatorViewHidden
    }

	private var indexPathForLastItem: IndexPath? {
		let lastSection = numberOfSections - 1
		guard lastSection >= 0, numberOfItems(inSection: lastSection) > 0 else { return nil }
		return IndexPath(item: numberOfItems(inSection: lastSection) - 1, section: lastSection)
	}

	var messagesCollectionViewFlowLayout: MessagesCollectionViewFlowLayout {
		guard let layout = collectionViewLayout as? MessagesCollectionViewFlowLayout else {
			fatalError()
		}
		return layout
	}

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        endEditing(true)
    }
    
	// MARK: - Initializers
	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: frame, collectionViewLayout: layout)
		backgroundColor = .collectionViewBackground
		setupGestureRecognizers()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(frame: .zero, collectionViewLayout: MessagesCollectionViewFlowLayout())
	}

	convenience init() {
		self.init(frame: .zero, collectionViewLayout: MessagesCollectionViewFlowLayout())
	}

	// MARK: - Methods
	private func setupGestureRecognizers() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
		tapGesture.delaysTouchesBegan = true
		addGestureRecognizer(tapGesture)
	}
	
	@objc
	func handleTapGesture(_ gesture: UIGestureRecognizer) {
        superview?.endEditing(true)
		guard gesture.state == .ended else { return }
		let touchLocation = gesture.location(in: self)
		guard let indexPath = indexPathForItem(at: touchLocation) else { return }

		let cell = cellForItem(at: indexPath) as? ChatBaseCell
       
		cell?.handleTapGesture(gesture)
	}
	
	func scrollToLastItem(at pos: UICollectionView.ScrollPosition = .bottom, animated: Bool = true) {
		guard numberOfSections > 0 else { return }
		
		let lastSection = numberOfSections - 1
		let lastItemIndex = numberOfItems(inSection: lastSection) - 1
		
		guard lastItemIndex >= 0 else { return }
		
		let indexPath = IndexPath(item: lastItemIndex, section: lastSection)
		scrollToItem(at: indexPath, at: pos, animated: animated)
	}
	
	func reloadDataAndKeepOffset() {
		// stop scrolling
		setContentOffset(contentOffset, animated: false)
		
		// calculate the offset and reloadData
		let beforeContentSize = contentSize
		reloadData()
		layoutIfNeeded()
		let afterContentSize = contentSize
		
		// reset the contentOffset after data is updated
		let xOffset = contentOffset.x + (afterContentSize.width - beforeContentSize.width)
		let yOffset = contentOffset.y + (afterContentSize.height - beforeContentSize.height)
		let newOffset = CGPoint(x: xOffset, y: yOffset)
		setContentOffset(newOffset, animated: false)
	}

	// MARK: - Typing Indicator API
	/// Notifies the layout that the typing indicator will change state
	///
	/// - Parameters:
	///   - isHidden: A Boolean value that is to be the new state of the typing indicator
	func setTypingIndicatorViewHidden(_ isHidden: Bool) {
		messagesCollectionViewFlowLayout.setTypingIndicatorViewHidden(isHidden)
	}
	
	/// A method that by default checks if the section is the last in the
	/// `messagesCollectionView` and that `isTypingIndicatorViewHidden`
	/// is FALSE
	///
	/// - Parameter section
	/// - Returns: A Boolean indicating if the TypingIndicator should be presented at the given section
	func isSectionReservedForTypingIndicator(_ section: Int) -> Bool {
		return messagesCollectionViewFlowLayout.isSectionReservedForTypingIndicator(section)
	}

	// MARK: - View Register/Dequeue
	/// Registers a particular cell using its reuse-identifier
	func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
		register(cellClass, forCellWithReuseIdentifier: String(describing: T.self))
	}

	/// Registers a reusable view for a specific SectionKind
	func register<T: UICollectionReusableView>(_ reusableViewClass: T.Type, forSupplementaryViewOfKind kind: String) {
		register(reusableViewClass,
				 forSupplementaryViewOfKind: kind,
				 withReuseIdentifier: String(describing: T.self))
	}
	
	/// Registers a nib with reusable view for a specific SectionKind
	func register<T: UICollectionReusableView>(_ nib: UINib? = UINib(nibName: String(describing: T.self), bundle: nil), headerFooterClassOfNib headerFooterClass: T.Type, forSupplementaryViewOfKind kind: String) {
		register(nib,
				 forSupplementaryViewOfKind: kind,
				 withReuseIdentifier: String(describing: T.self))
	}

	/// Generically dequeues a cell of the correct type allowing you to avoid scattering your code with guard-let-else-fatal
	func dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
		guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
			fatalError("Unable to dequeue \(String(describing: cellClass)) with reuseId of \(String(describing: T.self))")
		}
		return cell
	}

	/// Generically dequeues a header of the correct type allowing you to avoid scattering your code with guard-let-else-fatal
	func dequeueReusableHeaderView<T: UICollectionReusableView>(_ viewClass: T.Type, for indexPath: IndexPath) -> T {
		let view = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: T.self), for: indexPath)
		guard let viewType = view as? T else {
			fatalError("Unable to dequeue \(String(describing: viewClass)) with reuseId of \(String(describing: T.self))")
		}
		return viewType
	}

	/// Generically dequeues a footer of the correct type allowing you to avoid scattering your code with guard-let-else-fatal
	func dequeueReusableFooterView<T: UICollectionReusableView>(_ viewClass: T.Type, for indexPath: IndexPath) -> T {
		let view = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: String(describing: T.self), for: indexPath)
		guard let viewType = view as? T else {
			fatalError("Unable to dequeue \(String(describing: viewClass)) with reuseId of \(String(describing: T.self))")
		}
		return viewType
	}
}

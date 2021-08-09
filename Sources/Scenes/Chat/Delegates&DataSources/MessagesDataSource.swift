//
//  MessagesDataSource.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 14.05.2021.
//

import UIKit

/// An object that adopts the `MessagesDataSource` protocol is responsible for providing
/// the data required by a `MessagesCollectionView`.
 protocol MessagesDataSource: AnyObject {
	
	/// The message to be used for a `MessageCollectionViewCell` at the given `IndexPath`.
	///
	/// - Parameters:
	///   - indexPath: The `IndexPath` of the cell.
	///   - messagesCollectionView: The `MessagesCollectionView` in which the message will be displayed.
	func messageForItem(at indexPath: IndexPath) -> MessageCellViewModel

	/// The number of sections to be displayed in the `MessagesCollectionView`.
	///
	/// - Parameters:
	///   - messagesCollectionView: The `MessagesCollectionView` in which the messages will be displayed.
	func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int

	/// The number of cells to be displayed in the `MessagesCollectionView`.
	///
	/// - Parameters:
	///   - section: The number of the section in which the cells will be displayed.
	///   - messagesCollectionView: The `MessagesCollectionView` in which the messages will be displayed.
	/// - Note:
	///   The default implementation of this method returns 1. Putting each message in its own section.
	func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int

}

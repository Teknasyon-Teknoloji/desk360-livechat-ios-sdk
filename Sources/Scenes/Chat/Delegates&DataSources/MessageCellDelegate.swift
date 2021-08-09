//
//  MessageCellDelegate.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 14.05.2021.
//

import UIKit

/// A protocol used by `MessageContentCell` subclasses to detect taps in the cell's subviews.
protocol MessageCellDelegate: MessageLabelDelegate {

	/// Triggered when a tap occurs in the background of the cell.
	///
	/// - Parameters:
	///   - cell: The cell where the tap occurred.
	///
	/// - Note:
	/// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
	/// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
	/// method `messageForItem(at:indexPath:messagesCollectionView)`.
	func didTapBackground(in cell: ChatBaseCell)

	/// Triggered when a tap occurs in the `MessageContainerView`.
	///
	/// - Parameters:
	///   - cell: The cell where the tap occurred.
	///
	/// - Note:
	/// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
	/// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
	/// method `messageForItem(at:indexPath:messagesCollectionView)`.
	func didTapMessage(in cell: ChatBaseCell)

	/// Triggered when a tap occurs on the image.
	///
	/// - Parameters:
	///   - cell: The image where the touch occurred.
	///
	/// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
	/// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
	/// method `messageForItem(at:indexPath:messagesCollectionView)`.
	func didTapImage(in cell: ChatBaseCell, image: UIImage?)
	
	/// Triggered when a tap occurs on the image.
	///
	/// - Parameters:
	///   - cell: The image where the touch occurred.
	///
	/// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
	/// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
	/// method `messageForItem(at:indexPath:messagesCollectionView)`.
	func didTapVideo(in cell: ChatBaseCell, video item: ChatMediaItem?)
	
	/// Triggered when a tap occurs on the image.
	///
	/// - Parameters:
	///   - cell: The image where the touch occurred.
	///
	/// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
	/// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
	/// method `messageForItem(at:indexPath:messagesCollectionView)`.
	func didTapFile(in cell: ChatBaseCell, file item: ChatMediaItem?)
}

extension MessageCellDelegate {
	func didTapBackground(in cell: ChatBaseCell) {}
	func didTapMessage(in cell: ChatBaseCell) {}
	func didTapImage(in cell: ChatBaseCell, image: UIImage?) {}
	func didTapVideo(in cell: ChatBaseCell, video item: ChatMediaItem?) {}
	func didTapFile(in cell: ChatBaseCell, file item: ChatMediaItem?) {}
}

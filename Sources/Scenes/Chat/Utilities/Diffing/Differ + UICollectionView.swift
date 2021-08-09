//
//  Differ + UICollectionView.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 1.06.2021.
//

import UIKit

extension UICollectionView {
	
	func reload<T: Diffable>(
		changes: [Change<T>],
		section: Int,
		updateData: () -> Void,
		completion: ((Bool) -> Void)? = nil
	) {
		
		let changesWithIndexPath = IndexPathConverter.convert(changes: changes, section: section)
		
	//	performBatchUpdates({
			updateData()
			insideUpdate(changesWithIndexPath: changesWithIndexPath)
		// }, completion: { finished in
			// completion?(finished)
		// })
		
		outsideUpdate(changesWithIndexPath: changesWithIndexPath)
	}
	
	// MARK: - Helper
	
	private func insideUpdate(changesWithIndexPath: ChangeWithIndexPath) {
		changesWithIndexPath.deletes.executeIfPresent {
			deleteItems(at: $0)
		}
		
		changesWithIndexPath.inserts.executeIfPresent {
			if numberOfSections == 0 {
				reloadData()
			} else {
				Logger.log(event: .info, "Will insert at", $0)
				insertItems(at: $0)
			}
		}
		
		changesWithIndexPath.moves.executeIfPresent {
			$0.forEach { move in
				moveItem(at: move.from, to: move.to)
			}
		}
	}
	
	private func outsideUpdate(changesWithIndexPath: ChangeWithIndexPath) {
		changesWithIndexPath.replaces.executeIfPresent {
			self.reloadItems(at: $0)
		}
	}
}

struct ChangeWithIndexPath {
	
	let inserts: [IndexPath]
	let deletes: [IndexPath]
	let replaces: [IndexPath]
	let moves: [(from: IndexPath, to: IndexPath)]
	
	init(
		inserts: [IndexPath],
		deletes: [IndexPath],
		replaces: [IndexPath],
		moves: [(from: IndexPath, to: IndexPath)]
	) {
		
		self.inserts = inserts
		self.deletes = deletes
		self.replaces = replaces
		self.moves = moves
	}
}

struct IndexPathConverter {
	
	private init() {}
	
	static func convert<T>(changes: [Change<T>], section: Int) -> ChangeWithIndexPath {
		let inserts = changes.compactMap({ $0.insert }).map({ $0.index.toIndexPath(section: section) })
		let deletes = changes.compactMap({ $0.delete }).map({ $0.index.toIndexPath(section: section) })
		let replaces = changes.compactMap({ $0.replace }).map({ $0.index.toIndexPath(section: section) })
		let moves = changes.compactMap({ $0.move }).map {
			(
				from: $0.fromIndex.toIndexPath(section: section),
				to: $0.toIndex.toIndexPath(section: section)
			)
		}
		
		return ChangeWithIndexPath(
			inserts: inserts,
			deletes: deletes,
			replaces: replaces,
			moves: moves
		)
	}
}

extension Int {
	fileprivate func toIndexPath(section: Int) -> IndexPath {
		return IndexPath(item: 0, section: self)
	}
}

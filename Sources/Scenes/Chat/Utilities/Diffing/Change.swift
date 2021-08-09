//
//  Change.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 1.06.2021.
//

import Foundation

/// The computed changes from diff
///
/// - insert: Insert an item at index
/// - delete: Delete an item from index
/// - replace: Replace an item at index with another item
/// - move: Move the same item from this index to another index
enum Change<T> {
	case insert(Insert<T>)
	case delete(Delete<T>)
	case replace(Replace<T>)
	case move(Move<T>)
	
	var insert: Insert<T>? {
		if case .insert(let insert) = self {
			return insert
		}
		
		return nil
	}
	
	var delete: Delete<T>? {
		if case .delete(let delete) = self {
			return delete
		}
		return nil
	}
	
	var replace: Replace<T>? {
		if case .replace(let replace) = self {
			return replace
		}
		return nil
	}
	
	var move: Move<T>? {
		if case .move(let move) = self {
			return move
		}
		return nil
	}
	
	var item: T {
		switch self {
		case .delete(let delete):
			return delete.item
		case .insert(let insert):
			return insert.item
		case .move(let move):
			return move.item
		case .replace(let replace):
			return replace.newItem
		}
	}
	
	func map<NewModel>(_ transform: (T) -> NewModel) -> Change<NewModel> {
		switch self {
		case .delete(let delete):
			let newItem = transform(delete.item)
			return .delete(.init(item: newItem, index: self.delete?.index ?? -1))
		case .insert(let insert):
			let newItem = transform(insert.item)
			return .insert(.init(item: newItem, index: self.insert?.index ?? -1))
		case .move(let move):
			let newItem = transform(move.item)
			return .move(.init(item: newItem, fromIndex: self.move?.fromIndex ?? -1, toIndex: self.move?.toIndex ?? -1))
		case .replace(let replace):
			let oldItem = transform(replace.oldItem)
			let newItem = transform(replace.newItem)
			return .replace(.init(oldItem: oldItem, newItem: newItem, index: replace.index))
		}
		
	}
}

extension Change {
	struct Insert<T> {
		let item: T
		let index: Int
	}
	
	struct Delete<T> {
		let item: T
		let index: Int
	}
	
	struct Replace<T> {
		let oldItem: T
		let newItem: T
		let index: Int
	}
	
	struct Move<T> {
		let item: T
		let fromIndex: Int
		let toIndex: Int
	}
}

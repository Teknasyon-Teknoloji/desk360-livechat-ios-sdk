//
//  Diffable.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 1.06.2021.
//

import Foundation

protocol Diffable {
	associatedtype DiffId: Hashable
	
	var diffId: DiffId { get }
	static func compareContent(_ a: Self, _ b: Self) -> Bool
}

extension Diffable where Self: Hashable {
	var diffId: Self {
		return self
	}
	
	static func compareContent(_ a: Self, _ b: Self) -> Bool {
		return a == b
	}
}

extension Int: Diffable {}
extension String: Diffable {}
extension Character: Diffable {}
extension UUID: Diffable {}
extension Message: Diffable {
	var diffId: String {
		id
	}
	
	static func compareContent(_ a: Message, _ b: Message) -> Bool {
		a.id == b.id && a.content == b.content && a.status == b.status
	}
	
	typealias DiffId = String
}

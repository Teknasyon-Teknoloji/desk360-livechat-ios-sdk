//
//  StorageCompatible.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 22.04.2021.
//

import Foundation
import PersistenceKit

extension Settings: Identifiable {
	public static var idKey = \Settings.companyID

}

// extension Ticket: Identifiable, Equatable {
//
//	public static func == (lhs: Ticket, rhs: Ticket) -> Bool {
//		return lhs.id == rhs.id
//	}
//
//	/// Id Type.
//	public static var idKey = \Ticket.id
//
// }

extension ChatMediaItem: Identifiable {
	typealias ID = String
	static var idKey: WritableKeyPath<ChatMediaItem, String> {
		return \ChatMediaItem.fileName
	}
}

extension RecentMessage: Identifiable {
    typealias ID = String
    static var idKey: WritableKeyPath<RecentMessage, String> {
        return \RecentMessage.message.id
    }
}

extension Message: Identifiable {
    typealias ID = String
    static var idKey: WritableKeyPath<Message, String> {
        return \Message.id
    }
}

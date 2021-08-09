//
//  MessagesSnapshot.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 5.07.2021.
//

import Foundation

class MessageSection: Hashable {
    internal init(date: String, messages: [MessageCellViewModel]) {
        self.date = date
        self.messages = messages
    }
    
    let date: String
    var messages: [MessageCellViewModel]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }
    
    static func == (lhs: MessageSection, rhs: MessageSection) -> Bool {
        lhs.date == rhs.date && rhs.messages == lhs.messages
    }
}

enum IndexPathDiff {
    case insert(indexPath: IndexPath)
    case update(indexpath: IndexPath)
    
    var indexPth: IndexPath {
        switch self {
        case let .insert(indexPath):
            return indexPath
        case let .update(indexPath):
            return indexPath
        }
    }
}

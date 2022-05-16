//
//  Message.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 1.06.2021.
//

import FirebaseCore
import FirebaseDatabase
import Foundation
import UIKit

final class Message: Equatable, Codable {
	var id: String
	let content: String
	let createdAt: Date
	let updatedAt: Date
	let senderName: String
	let agentID: Int?
	let status: Status
	let isCustomer: Bool
	
	var attachment: Attachment?
	var mediaItem: ChatMediaItem?
	
	var kind: MessageKind {
		MessageKindMapper.map(message: self)
	}
	
	init(
		id: String,
		content: String,
		createdAt: Date,
		updatedAt: Date,
		senderName: String,
		agentID: Int?,
		status: Message.Status,
		attachment: Attachment?,
		isCustomer: Bool,
		mediaItem: ChatMediaItem?
	) {
		self.id = id
		self.content = content
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		self.senderName = senderName
		self.agentID = agentID
		self.status = status
		self.attachment = attachment
		self.isCustomer = isCustomer
		self.mediaItem = mediaItem
	}
	
	init?(from json: JSON) {
		guard let id: String = json.resolve(keyPath: "id") else { return nil }
		self.id = id
		self.content = json.resolve(keyPath: "content", orDefault: "")
        let _createdAt: TimeInterval = json.resolve(keyPath: "created_at", orDefault: -1)
        let _updatedAt: TimeInterval = json.resolve(keyPath: "created_at", orDefault: -1)
		self.createdAt = MessageDateFormatter.shared.date(from: _createdAt)
		self.updatedAt = MessageDateFormatter.shared.date(from: _updatedAt)
		self.senderName = json.resolve(keyPath: "sender_name", orDefault: "")
		self.agentID = json.resolve(keyPath: "receiver", orDefault: -1)
		let rawStatus = json.resolve(keyPath: "status", orDefault: "")
		let status = Status(rawValue: rawStatus)
		self.status = status ?? .failedToSend
		self.isCustomer = json.resolve(keyPath: "is_customer", orDefault: false)
		let attachmentsJson: [String: Any] = json.resolve(keyPath: "attachments", orDefault: [:])
		attachment = Attachment(from: attachmentsJson)
	}
	
	convenience init() {
		self.init(id: "", content: "", createdAt: .init(), updatedAt: .init(), senderName: "", agentID: nil, status: .sent, attachment: nil, isCustomer: false, mediaItem: nil)
	}
	
	static func == (lhs: Message, rhs: Message) -> Bool {
		lhs.id == rhs.id && lhs.content == rhs.content && lhs.createdAt == rhs.createdAt && lhs.status == rhs.status
	}
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case createdAt
        case updatedAt
        case senderName
        case agentID
        case status
        case isCustomer
        case attachment
        case mediaItem
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        senderName = try container.decode(String.self, forKey: .senderName)
        agentID = try container.decode(Int.self, forKey: .agentID)
        status = try container.decode(Status.self, forKey: .status)
        isCustomer = try container.decode(Bool.self, forKey: .isCustomer)
        attachment = try container.decodeIfPresent(Attachment.self, forKey: .attachment)
        mediaItem = try container.decodeIfPresent(ChatMediaItem.self, forKey: .mediaItem)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(senderName, forKey: .senderName)
        try container.encode(agentID, forKey: .agentID)
        try container.encode(status, forKey: .status)
        try container.encode(isCustomer, forKey: .isCustomer)
        try container.encodeIfPresent(attachment, forKey: .attachment)
        try container.encodeIfPresent(mediaItem, forKey: .mediaItem)
    }
}

extension Message {
	enum Status: String, Codable {
		case sending
		case sent
        case delivered
		case read
		case failedToSend
	}
}

extension Message {
	typealias JSON = [String: Any]
	
	func toJSON(uid: String) -> JSON {
		var message = [String: Any]()
		message["content"] = content
        message["created_at"] = createdAt.millisecondsSince1970
        message["updated_at"] = updatedAt.millisecondsSince1970
        message["timestamp"] = true
		message["is_customer"] = true
        message["receiver"] = agentID ?? "" // 140
		message["sender"] = uid
		message["session"] = uid
		message["sender_name"] = senderName
		message["source"] = "iOS"
		
		if let attachment = attachment, let type = attachment.type {
			message["attachments"] = [type.rawValue: attachment.toJSON()]
			message["status"] = Status.sent.rawValue
		
		} else {
			message["status"] = Status.sent.rawValue
		}
		
		return message
	}
}

fileprivate final class MessageKindMapper {
	static func map(message: Message) -> MessageKind {
		let content = message.content
		if EmojiDetector.shared.isEmoji(character: content) {
			return .emoji(content)
		} else if let attachment = message.attachment, let type = attachment.mapToMessageType() {
            return type
		} else if let item = message.mediaItem {
			let kind = item.type
			switch kind {
			case .images: return .photo(item)
			case .videos: return .video(item)
			case .files:
				return .document(item)
			case .others: return .document(item)
			}
		} else {
			return .text(content)
		}
	}
}

//
//  MediaUploadRespose.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 31.05.2021.
//

import UIKit

struct Attachment: Codable {
	var images: [FileInfo]?
	var videos: [FileInfo]?
	var files: [FileInfo]?
	var others: [FileInfo]?
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		images = try container.decodeIfPresent([FileInfo].self, forKey: .images)
		videos = try container.decodeIfPresent([FileInfo].self, forKey: .videos)
		files  = try container.decodeIfPresent([FileInfo].self, forKey: .files)
		others = try container.decodeIfPresent([FileInfo].self, forKey: .others)
	}
	
	func mapToMessageType() -> MessageKind? {
		switch type {
		case .files:
			return files?.first?.map()
		case .images:
			return images?.first?.map()
		case .others:
			return others?.first?.map()
		case .videos:
			return videos?.first?.map()
		case .none:
			return .none
		}
	}
	
	var fileName: String {
		switch type {
		case .files:
			return files?.first?.name ?? ""
		case .images:
			return images?.first?.name ?? ""
		case .others:
			return others?.first?.name ?? ""
		case .videos:
			return videos?.first?.name ?? ""
		case .none:
			return ""
		}
	}
	
	var fileUrl: URL? {
		var urlStr: String
		switch type {
		case .files:
			urlStr = files?.first?.url ?? ""
		case .images:
			urlStr = images?.first?.url ?? ""
		case .others:
			urlStr = others?.first?.url ?? ""
		case .videos:
			urlStr = videos?.first?.url ?? ""
		case .none:
			urlStr = ""
		}
		
		return URL(string: urlStr)
	}
}

extension Attachment {
	struct FileInfo: Codable {
		let url: String
		let name: String
		let type: String
		let aws: Bool
	}
}

extension Attachment.FileInfo {
	func toJSON() -> [String: Any] {
		[
			"url": url,
			"aws": aws,
			"type": type,
			"name": name
		]
	}
	
	func map() -> MessageKind? {
		let ext = File.Extension(rawValue: name.fileExtension)
		switch type {
		case "file", "other":
			return .document(ChatMediaItem(fileName: name, url: URL(string: url), image: nil, data: nil, placeholderImage: nil, mediaExtension: ext, type: .files))
		case "image":
			return .photo(ChatMediaItem(fileName: name, url: URL(string: url), image: nil, data: nil, placeholderImage: nil, mediaExtension: ext, type: .images))
		case "video":
			return .video(ChatMediaItem(fileName: name, url: URL(string: url), image: nil, data: nil, placeholderImage: nil, mediaExtension: ext, type: .videos))
		default:
			return nil
		}
	}
}

private extension Attachment {
	enum CodingKeys: String, CodingKey {
		case images
		case videos
		case files
		case others
	}
}

extension Attachment {
	var type: Kind? {
		if images != nil {
			return .images
		}
		
		if videos != nil {
			return .videos
		}
		
		if files != nil {
			return .files
		}
		
		if others != nil {
			return .others
		} else {
			return nil
		}
	}
	
	enum Kind: String, Codable {
		case images
		case videos
		case files
		case others
	}
}

extension Attachment {
	func toJSON() -> Any {
		var attachments: [[String: Any]]
		guard let type = type else { return [:] }
		switch type {
		case .images:
			attachments = images.flatMap { $0.map { $0.toJSON() } } ?? []
		case .files:
			attachments = files.flatMap { $0.map { $0.toJSON() } } ?? []
		case .videos:
			attachments = videos.flatMap { $0.map { $0.toJSON() } } ?? []
		case .others:
			attachments = others.flatMap { $0.map { $0.toJSON() } } ?? []
		}
		return attachments
	}
}

extension Attachment {
	init?(from json: [String: Any]) {
		json.forEach { key, value in
			guard let kind = Kind(rawValue: key), let value = value as? [[String: Any]] else { return }
			switch kind {
			case .files:
				files = value.compactMap { FileInfo(from: $0) }
			case .images:
				images = value.compactMap { FileInfo(from: $0) }
			case .videos:
				videos = value.compactMap { FileInfo(from: $0) }
			case .others:
				others = value.compactMap { FileInfo(from: $0) }
			}
		}
	}
}

extension Attachment.FileInfo {
	init?(from json: [String: Any]) {
		guard let url: String = json.resolve(keyPath: "url") else { return nil }
		self.url = url
		guard let name: String = json.resolve(keyPath: "name") else { return nil }
		self.name = name
		guard let type: String = json.resolve(keyPath: "type") else { return nil }
		self.type = type
		guard let aws: Bool = json.resolve(keyPath: "aws") else { return nil }
		self.aws = aws
	}
}

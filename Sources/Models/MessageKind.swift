//
//  MessageKind.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 4.05.2021.
//

import Foundation
import UIKit

enum MessageKind {
	case text(String)
	case attributedText(NSAttributedString)
	case photo(ChatMediaItem)
	case video(ChatMediaItem)
	case document(ChatMediaItem)
	case emoji(String)
	case linkPreview(LinkItem)
}

extension MessageKind {
	var textMessageKind: MessageKind {
		switch self {
		case .linkPreview(let linkItem):
			return linkItem.textKind
		case .text, .emoji, .attributedText:
			return self
		default:
			fatalError("textMessageKind not supported for messageKind: \(self)")
		}
	}
}

/// A standard protocol representing a message.
protocol MessageViewModelType {
	/// The kind of message and its underlying kind.
	var kind: MessageKind { get }
	
	var isFromCurrentUser: Bool { get }
	
	var messageError: Error? { get set }
	
	var isSentSuccessfully: Bool { get }
	
}

extension MessageViewModelType {
	var isSentSuccessfully: Bool {
		messageError == nil
	}
}

struct ChatMediaItem: Codable {
	var fileName: String
	var url: URL?
	var image: UIImage?
	var data: Data?
	var placeholderImage: UIImage?
	var mediaExtension: File.Extension?
	var type: Attachment.Kind
	var localUrl: URL?
	
	init(
		fileName: String,
		url: URL? = nil,
		image: UIImage? = nil,
		data: Data? = nil,
		placeholderImage: UIImage?,
		mediaExtension: File.Extension? = nil,
		type: Attachment.Kind,
		localUrl: URL? = nil
	) {
		self.fileName = fileName
		self.url = url
		self.image = image
		self.data = data
		self.placeholderImage = placeholderImage
		self.mediaExtension = mediaExtension
		self.type = type
		self.localUrl = localUrl
	}
	
	enum CodingKeys: String, CodingKey {
		case fileName
		case url
		case image
		case data
		case placeholderImage
		case mediaExtension
		case type
		case localUrl
	}
	
	func encode(to encoder: Encoder) throws {
		var contanter = encoder.container(keyedBy: CodingKeys.self)
		if let image = image {
			try contanter.encode(image, forKey: .image)
		}
		
		if let placeholder = placeholderImage {
			try contanter.encode(placeholder, forKey: .placeholderImage)
		}
		try contanter.encode(fileName, forKey: .fileName)
		try contanter.encodeIfPresent(url, forKey: .url)
		try contanter.encodeIfPresent(data, forKey: .data)
		try contanter.encodeIfPresent(mediaExtension, forKey: .mediaExtension)
		try contanter.encodeIfPresent(type, forKey: .type)
		try contanter.encodeIfPresent(localUrl, forKey: .localUrl)
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.fileName = try container.decode(String.self, forKey: .fileName)
		self.url = try container.decodeIfPresent(URL.self, forKey: .url)
		self.image = try container.decodeIfPresent(UIImage.self, forKey: .image)
		self.data = try container.decodeIfPresent(Data.self, forKey: .data)
		self.placeholderImage = try container.decodeIfPresent(UIImage.self, forKey: .placeholderImage)
		self.mediaExtension = try container.decodeIfPresent(File.Extension.self, forKey: .mediaExtension)
		self.type = try container.decode(Attachment.Kind.self, forKey: .type)
		self.localUrl = try container.decodeIfPresent(URL.self, forKey: .localUrl)
	}
	
	var thumbnail: UIImage? {
		guard let fileExtension = mediaExtension else { return nil }
		return Images.createImage(resources: "Images/\(fileExtension.rawValue.lowercased())")
	}
}

enum ImageEncodingQuality {
	case png
	case jpeg(quality: CGFloat)
}

extension KeyedEncodingContainer {
	mutating func encode(
		_ value: UIImage,
		forKey key: KeyedEncodingContainer.Key,
		quality: ImageEncodingQuality = .png
	) throws {
		let imageData: Data?
		switch quality {
		case .png:
			imageData = value.pngData()
		case .jpeg(let quality):
			imageData = value.jpegData(compressionQuality: quality)
		}
		guard let data = imageData else {
			throw EncodingError.invalidValue(
				value,
				EncodingError.Context(codingPath: [key], debugDescription: "Failed convert UIImage to data")
			)
		}
		try encode(data, forKey: key)
	}
}

extension KeyedDecodingContainer {
	func decode(_ type: UIImage.Type, forKey key: KeyedDecodingContainer.Key) throws -> UIImage {
		let imageData = try decode(Data.self, forKey: key)
		if let image = UIImage(data: imageData) {
			return image
		} else {
			throw DecodingError.dataCorrupted(
				DecodingError.Context(codingPath: [key], debugDescription: "Failed load UIImage from decoded data")
			)
		}
	}
	
	func decodeIfPresent(_ type: UIImage.Type, forKey key: KeyedDecodingContainer.Key) throws -> UIImage? {
		let imageData = try decodeIfPresent(Data.self, forKey: key)
		if let data = imageData, let image = UIImage(data: data) {
			return image
		} else {
			return nil
		}
	}
}

struct LinkItem {
	
	/// A link item needs a message to present, it can be a simple String or
	/// a NSAttributedString, but only one will be shown.
	/// LinkItem.text has priority over LinkeItem.attributedText.
	/// The message text.
	var text: String?
	var attributedText: NSAttributedString?
	var url: URL
	var title: String?
	var teaser: String
	var thumbnailImage: UIImage
}

extension LinkItem {
	var textKind: MessageKind {
		let kind: MessageKind
		if let text = self.text {
			kind = .text(text)
		} else if let attributedText = self.attributedText {
			kind = .attributedText(attributedText)
		} else {
			fatalError("LinkItem must have \"text\" or \"attributedText\"")
		}
		return kind
	}
}

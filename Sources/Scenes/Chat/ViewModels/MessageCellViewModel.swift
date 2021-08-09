//
//  MessageCellViewModel.swift
//  Example
//
//  Created by Ali Ammar Hilal on 13.05.2021.
//

import Alamofire
import Foundation

typealias Detectors = Set<DetectorType>
typealias Result = Swift.Result

class MessageCellViewModel: MessageViewModelType, Diffable {
	var id: String {
		message.id
	}
	
	var messageError: Error?
	var message: Message
    var isSeen = false
    
	var state: Message.Status {
		return message.status
	}
	
	var isIncomingMessage: Bool {
		!message.isCustomer
	}
	
	var kind: MessageKind {
		message.kind
	}
	
	var isFromCurrentUser: Bool {
		message.isCustomer
	}
	
	init(message: Message) {
		self.message = message
	}
	
	var mediaItem: ChatMediaItem?
	
	var isDownloading = false
    var isUploading = false
    
	var messageDetectors: Detectors {
		[.url, .address, .date, .phoneNumber, .hashtag, .mention]
	}
	
	var isCached: Bool {
		return Storage.messageStore.hasObject(withId: getFileNameOfAtachment())
	}
	
	var cachedMediaItem: ChatMediaItem? {
		Storage.messageStore.object(withId: getFileNameOfAtachment())
	}
	
	var uploadProgress: ((CGFloat) -> Void)?
	
	func setProgress(_ progress: CGFloat) {
		uploadProgress?(progress)
	}
	
	func getFileNameOfAtachment() -> String {
		guard let attachment = message.attachment, let type = attachment.type else { return "" }
		var fileName: String = ""
		switch type {
		case .files:
			fileName = attachment.files?.first?.name ?? ""
		case .images:
			fileName = attachment.images?.first?.name ?? ""
		case .others:
			fileName = attachment.others?.first?.name ?? ""
		case .videos:
			fileName = attachment.videos?.first?.name ?? ""
		}
		return fileName
	}
	
	func downloadFile(progress: (@escaping(Progress) -> Void), completion: @escaping(Result<ChatMediaItem, Error>) -> Void) {
		
		guard let attachment = message.attachment, let type = attachment.type else { return }
		self.isDownloading = true
		let messageType = attachment.mapToMessageType()
		var fileName: String = ""
		var url: URL?
		
		switch type {
		case .files:
			url = URL(string: attachment.files?.first?.url ?? "")
			fileName = attachment.files?.first?.name ?? ""
		case .images:
			url = URL(string: attachment.images?.first?.url ?? "")
			fileName = attachment.images?.first?.name ?? ""
		case .others:
			url = URL(string: attachment.others?.first?.url ?? "")
			fileName = attachment.others?.first?.name ?? ""
		case .videos:
			url = URL(string: attachment.videos?.first?.url ?? "")
			fileName = attachment.videos?.first?.name ?? ""
		}
		
		guard let url = url else { return }
		var mediaExtension: File.Extension = .jpeg
	
		switch messageType {
		case .document(let item):
			print(item)
			if let ext = item.mediaExtension {
				mediaExtension = ext
			} else {
				mediaExtension = .pdf
			}
			
		case  .video(let item):
			if let ext = item.mediaExtension {
				mediaExtension = ext
			} else {
				mediaExtension = .mp4
			}
		// downloadVideo(progress: progress, completion: completion)
		default:
			break
		}
		
		if Storage.messageStore.hasObject(withId: fileName) {
			if let item = Storage.messageStore.object(withId: fileName) {
				completion(.success(item))
				return
			}
		}
		
        AF.download(url)
			.downloadProgress(queue: .main, closure: { _progress in
				progress(_progress)
			})
			.responseData { response in
				switch response.result {
				case .success(let data):
					Logger.log(event: .info, fileName)
					let documentDir = FileManager.default.getDocumentsDirectory()
					let localUrl = documentDir.appendingPathComponent(fileName)
					do {
						try data.write(to: localUrl, options: .atomic)
						
					} catch {
						Logger.logError(error)
					}
					
					let item = ChatMediaItem(
						fileName: fileName,
						url: url,
						image: nil,
						data: data,
						placeholderImage: nil,
						mediaExtension: mediaExtension,
						type: attachment.type ?? .files,
						localUrl: localUrl
					)
					self.mediaItem = item
					self.isDownloading = false
					try? Storage.messageStore.save(item)
					completion(.success(item))
				case .failure(let error):
                    self.messageError = error
                    completion(.failure(error))
                    Logger.logError(error)
				}
			}
	}
}

extension MessageCellViewModel: Hashable {
	static func == (lhs: MessageCellViewModel, rhs: MessageCellViewModel) -> Bool {
		lhs.message == rhs.message
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

extension FileManager {
	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
	}
}

//
//  ChatViewModel.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 27.04.2021.
//

import Alamofire
import Foundation
import CloudKit
import FirebaseDatabase

protocol ChatDeletgate: AnyObject {
    func didRecieveNewMessage(_ newMessage: RecentMessage)
}

class ChatViewModel {
	weak private var router: Coordinator<MainRoute>?
	// private let agentProvider: AgentProvider
	private let messageProvider: MessagingProvider
	private let fileUploader: FileUploader
    var agent: Agent?
	let userCredentials: Credentials
	private let sessionProvider: SessionProvider
	
	private var _messages: [Message] = []
	var messages: [MessageSection] = []
    
    var isConnected: Bool {
        NetworkReachabilityManager.default?.isReachable ?? false
    }
    
	var reload: (() -> Void)?
	var agentHandler: ((Agent) -> Void)?
	static var sessionID: String?
    
    weak var delegate: ChatDeletgate?
    
	init(
		router: Coordinator<MainRoute>? = nil,
		agent: Agent?,
		messageProvider: MessagingProvider,
		fileUploader: FileUploader,
		sessionProvider: SessionProvider,
		credentials: Credentials
	) {
		self.router = router
		self.agent = agent
		self.messageProvider = messageProvider
		self.fileUploader = fileUploader
		self.sessionProvider = sessionProvider
		self.userCredentials = credentials
		Session.isActive = true
        try? Storage.isActiveConverationAvailable.save(true)
		Self.sessionID = Session.ID
	}
	
	func listenForTypingEvents(complection: @escaping((Bool) -> Void)) {
        guard let agent = agent else { return }
		messageProvider.listenFortypingEvents(from: agent.id, completion: complection)
	}
	
	func sendTypingEvents() {
		messageProvider.sendTypingEvents()
	}
	
    func shouldRecieveNotifications(_ value: Bool) {
        messageProvider.shouldRecieveNotifications(value)
    }
    
	func send(message: MessageKind, completion: @escaping((Message) -> Void)) {
		switch message {
		case .attributedText(let text):
			let string = text.string.trimmingCharacters(in: .whitespacesAndNewlines)
			self.sendMessage(string, completion: completion)
		case .emoji(let text), .text(let text):
			self.sendMessage(text, completion: completion)
		case .photo(let item), .video(let item), .document(let item):
			//			guard let data = item.data else { return }
			//			self.sendFile(data, extension: item.mediaExtension ?? .jpeg)
			self.send(item: item as ChatMediaItem)
		case .linkPreview:
			break
		}
	}
	
    func checkConnectivity(listener: @escaping ((NetworkReachabilityManager.NetworkReachabilityStatus) -> Void)) {
        NetworkReachabilityManager.default?.startListening(onQueue: .main, onUpdatePerforming: listener)
    }
    
	func receive(completion: @escaping ([IndexPathDiff]) -> Void) {
        if let agent = agent, Session.activeConversation == nil {
            Session.activeConversation = RecentMessage(agent: agent, message: Message(id: UUID.init().uuidString, content: "", createdAt: Date(), updatedAt: Date(), senderName: "", agentID: agent.id, status: .sent, attachment: nil, isCustomer: true, mediaItem: nil))
        }
        
        messageProvider.listenForMessages(ofSession: Session.ID, completion: { result in
        
			DispatchQueue.global(qos: .background).async {
				let changedItems = result.changes.map { $0.item }.sorted(by: { $0.createdAt < $1.createdAt })
				var changedSections = [IndexPathDiff]()
				for item in changedItems {
					let itemSection = MessageDateFormatter().dateForHeader(from: item.createdAt)
					if let sectionIndex = self.messages.firstIndex(where: { $0.date == itemSection }) {
						var messages = self.messages[sectionIndex].messages
						if let id = messages.firstIndex(where: { $0.message.id == item.id }) {
							messages[id].message = item
							let indexPath = IndexPath(item: id, section: sectionIndex)
							changedSections.append(.update(indexpath: indexPath))
						} else {
							messages.append(.init(message: item))
							let indexPath = IndexPath(item: messages.unique(map: { $0.id }).count - 1, section: sectionIndex)
							changedSections.append(.insert(indexPath: indexPath))
						}
						self.messages[sectionIndex].messages = messages.unique(map: { $0.id })
					} else {
						self.messages.append(.init(date: itemSection, messages: [.init(message: item)]))
						let indexPath = IndexPath(item: 0, section: self.messages.count - 1)
						changedSections.append(.insert(indexPath: indexPath))
					}
				}
                self._messages = result.allMessages
				DispatchQueue.main.async {
                    if let message = result.allMessages.last, let agent = self.agent {
                        let recentMessage = RecentMessage(agent: agent, message: message)
                        Session.activeConversation = recentMessage
                        self.delegate?.didRecieveNewMessage(recentMessage)
                    }
					completion(changedSections)
				}
			}
		}, agent: { newAgent in
			guard let newAgent = newAgent else {
				return
			}
            self.agent = newAgent
			if let message = self.messages.last?.messages.last?.message {
				Session.activeConversation = RecentMessage(agent: newAgent, message: message)
            }
			self.agentHandler?(newAgent)
        }, ended: { isEnded in
            if isEnded {
                Flow.delay(for: 0) {
                    Session.terminate(forceDeleteCreds: false)
                    self.router?.trigger(.sessionTermination(agent: self.agent))
                }
            }
        })
	}
	
	private func sendMessage(_ content: String, attachment: Attachment? = nil, completion: @escaping((Message) -> Void)) {
        let messageID = Database.liveChatDB.reference(withPath: "messages").childByAutoId().url.components(separatedBy: "/").last ?? UUID().uuidString
 
		let message = Message(
			id: messageID,
            content: content.trim().condenseWhitespace(),
			createdAt: Date(),
			updatedAt: Date(),
			senderName: userCredentials.name,
			agentID: agent?.id,
			status: .sent,
			attachment: attachment,
			isCustomer: true,
			mediaItem: nil
		)
		
        if self.messages.isEmpty {
            let date = MessageDateFormatter.shared.dateForHeader(from: message.createdAt)
            self.messages.append(MessageSection(date: date, messages: [.init(message: message)]))
        } else {
            self.messages.last?.messages.append(.init(message: message))
        }
        
        completion(message)
        
		if let chatbot = Storage.settings.object?.chatbot, chatbot == true {
			_messages.append(message)
			reload?()
			completion(message)
			messageProvider.sendChatBootMessage(message: content).on { _ in
				Logger.Log("Suceess")
				// completion(message)
				
			} failure: { error in
                self.setError(forMessage: message, error: error)
				Logger.logError(error)
			}
            
		} else {
			messageProvider
				.send(message: message)
				.on(success: { _ in
					// Logger.Log(message)
					
					// completion(message)
				}, failure: { error in
					// completion()
                    self.setError(forMessage: message, error: error)
					Logger.logError(error)
				})
		}
	}
	
	private func send(item: ChatMediaItem) {
        let messageID = Database.liveChatDB.reference(withPath: "messages").childByAutoId().url.components(separatedBy: "/").last ?? UUID().uuidString
		let message = Message(
			id: messageID,
			content: "",
			createdAt: Date(),
			updatedAt: Date(),
			senderName: userCredentials.name,
			agentID: agent?.id,
			status: .sent,
			attachment: nil,
			isCustomer: true,
			mediaItem: item
		)
		
		messageProvider.enqueue(message: message)

		_messages.append(message)

		if messages.isEmpty {
			let date = MessageDateFormatter.shared.dateForHeader(from: message.createdAt)
			messages.append(.init(date: date, messages: [.init(message: message)]))
		} else {
			messages.last?.messages.append(.init(message: message))
		}
    
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
			self.reload?()
		}
        
        messageViewModel(ofID: message.id)?.isUploading = true
		sendFile(from: item, attachedWith: message)
	}
	
	private func sendFile(from item: ChatMediaItem, attachedWith message: Message) {
		guard let data = item.data else { return }
		let file = File(name: item.fileName, content: data, extension: item.mediaExtension ?? .jpeg, attachedMessageID: message.id)
        let messageViewModel = messageViewModel(ofID: message.id)
        messageViewModel?.isUploading = true
		fileUploader
			.upload(file: file) { progress in
				self.messages.forEach { section in
					let vm = section.messages.first(where: { $0.id == message.id })
					vm?.setProgress(progress)
				}
			} then: { result in
                messageViewModel?.isUploading = false
				switch result {
				case .success(let attachment):
					guard let attachment = attachment else { return }
					message.attachment = attachment
					
					let fileName = attachment.fileName
					let documentDir = FileManager.default.getDocumentsDirectory()
					let localUrl = documentDir.appendingPathComponent(fileName)
					try? data.write(to: localUrl, options: .atomic)
					
					let item = ChatMediaItem(
						fileName: fileName,
						url: attachment.fileUrl,
						image: item.image,
						data: item.data,
						placeholderImage: item.placeholderImage,
						mediaExtension: item.mediaExtension,
						type: attachment.type ?? .files,
						localUrl: localUrl
					)
					try? Storage.messageStore.save(item)
					
					self.messageProvider.send(message: message)
						.on { message in
							Logger.Log(message)
                          
						} failure: { err in
                            self.setError(forMessage: message, error: err)
							Logger.logError(err)
						}
					
				case .failure(let error):
                    self.setError(forMessage: message, error: error)
					Logger.logError(error)
				}
			}
	}
	
    private func setError(forMessage message: Message, error: Error) {
        messageViewModel(ofID: message.id)?.messageError = error
        self.reload?()
    }
    
    private func messageViewModel(ofID id: String) -> MessageCellViewModel? {
        let messages = self.messages.flatMap { $0.messages }
        return messages.first(where: { $0.message.id == id })
    }
    
	func endChat() -> Future<Void, Error> {
		let sessionId = Session.ID

		if sessionId.isEmpty {
			let promise = Promise<Void, Error>()
			promise.fail(error: AnyError(message: ""))
			return promise.future
		} else {
			return sessionProvider
				.terminate(sessionID: sessionId)
				.observe(on: .main)
				.map({ _ in
					Session.terminate(forceDeleteCreds: false)
					self.router?.trigger(.sessionTermination(agent: self.agent, sessionId: sessionId))
			})
		}
	}
	
	func prepareTranscript() {
		router?.trigger(.transcript)
	}
	
	func back() {
		router?.trigger(.popToRoot)
	}
	
	func terminate() {
		Session.terminate(forceDeleteCreds: true)
		router?.trigger(.popToRoot)
	}
	
	static func clearSessionId() {
		sessionID?.removeAll()
	}
}

extension Array {
	func unique<T: Hashable>(map: ((Element) -> (T))) -> [Element] {
		var set = Set<T>() // the unique list kept in a Set for fast retrieval
		var arrayOrdered = [Element]() // keeping the unique list of elements but ordered
		for value in self {
			if !set.contains(map(value)) {
				set.insert(map(value))
				arrayOrdered.append(value)
			}
		}
		
		return arrayOrdered
	}
}

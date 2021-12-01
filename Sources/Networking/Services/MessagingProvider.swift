//
//  MessagingProvider.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 29.04.2021.
//

import FirebaseAuth
import FirebaseDatabase
import Foundation

struct MessagingResult {
	let changes: [Change<Message>]
	let allMessages: [Message]
}

protocol MessagingProvider {
	func send(message: Message) -> Future<Message, Error>
	func enqueue(message: Message)
	func updateMyMessageStatus(newStatus: Message.Status, messageID: String)
    func listenForMessages(ofSession sessionID: String, completion: @escaping((MessagingResult) -> Void), agent: (@escaping (Agent?) -> Void), ended: ((Bool) -> Void)?)
	func setAttachments(for messageID: String, attachments: Attachment)
    func sendOfflineMessage(_ message: OfflineMessage, customFields: [String: String]) -> Future<JSONAny?, Error>
	func sendChatBootMessage(message: String) -> Future<JSONAny?, Error>
	func listenFortypingEvents(from agentID: Int, completion: @escaping(Bool) -> Void)
	func sendTypingEvents()
    func shouldRecieveNotifications(_ value: Bool)
}

final class MessagingProviding: MessagingProvider {
    
    private var dataBase: Database { .liveChatDB }
    
    private let debouncer = Debouncer(delay: 0.25, queue: .global(qos: .background))
    private var oldMessages = [Message]()
    // private var messageQueue = [Message]()
    
    func shouldRecieveNotifications(_ value: Bool) {
        let uid = Auth.liveChat.currentUser?.uid ?? ""
        dataBase
            .reference(to: .agent(uid: uid))
            .updateChildValues(["notifications": value])
    }

	func enqueue(message: Message) {
		// oldMessages.
	}
	
	func updateMyMessageStatus(newStatus: Message.Status, messageID: String) {
		let uid = Auth.liveChat.currentUser?.uid ?? ""
		let ref = dataBase.reference(to: .myMessage(id: messageID, uid: uid))
		let json = ["status": newStatus.rawValue]
		ref.updateChildValues(json) { error, _ in
			if let error = error {
				Logger.logError(error)
				return
			}
		}
	}
    
    func updateAgentMessageStatus(newStatus: Message.Status, messageID: String, agentID: String) {
        let uid = Auth.liveChat.currentUser?.uid ?? ""
        let ref = dataBase.reference(to: .agentMessage(id: messageID, uid: uid, agentID: agentID))
        let json = ["status": newStatus.rawValue]
        ref.updateChildValues(json) { error, _ in
            if let error = error {
                Logger.logError(error)
                return
            }
        }
    }
    
	func send(message: Message) -> Future<Message, Error> {
		let uid = Auth.liveChat.currentUser?.uid ?? ""
		let promise = Promise<Message, Error>()
		
        guard message.isValid(uid: uid) else { return promise.future }
        
		self
			.dataBase
			.reference(to: .sendMessages(uid: uid, childID: message.id))
			.setValue(message.toJSON(uid: uid)) { error, ref in
				if let error = error {
					Logger.logError(error)
					promise.fail(error: error)
					return
				}
                promise.succeed(value: message)
			}
		
		return promise.future
	}
    
    var isEnded = false
    
	func listenForMessages(ofSession sessionID: String, completion: @escaping((MessagingResult) -> Void), agent: (@escaping (Agent?) -> Void), ended: ((Bool) -> Void)?) {
       
        DispatchQueue.global(qos: .background).async {
            let cachedMessages = Storage.mesaagesCache.allObjects()
            let changes = MessagesDiffer.diff(old: self.oldMessages, new: cachedMessages)
            Flow.async { completion(.init(changes: changes, allMessages: cachedMessages)) }
        }
        
        dataBase
            .reference(withPath: "messages/\(sessionID)").removeAllObservers()
        
        dataBase
			.reference(withPath: "messages/\(sessionID)")
            .observe(.value) { snapshot in
				// Logger.log(event: .info, "LISTEN ", snapshot.value ?? 0)
				guard let messagesDic = snapshot.value as? [String: [String: Any]] else {
					Logger.log(event: .error, "Could not decode messages")
                    ended?(true)
                    self.isEnded = true
					return
				}

                self.isEnded = false
				DispatchQueue.global(qos: .background).async {
					//				messagesDic.logAsJson(title: #function)
					var newMessages = [Message]()
					for message in messagesDic {
                        let mssgs = message.value.compactMap { key, value -> [String: Any]? in
                            if key == "session" { return nil }
							var _message = value as? [String: Any]
							_message?["id"] = key
                            _message?["parent"] = message.key
							return _message
						}
						
						mssgs.forEach { json in
							guard let msg = Message(from: json) else { return }
                            if msg.status != .read && !msg.isCustomer, let parentID = json["parent"] as? String {
                                self.updateMessageStatus(message: msg, parentID: parentID)
                            }
							newMessages.append(msg)
						}
					}
					
                    newMessages.sort(by: { $0.createdAt < $1.createdAt })
//                                        self.oldMessages.sort(by: { $0.createdAt < $1.createdAt })
//
                    try? Storage.mesaagesCache.save(newMessages)
                    if self.oldMessages.isEmpty {
                        let changes = MessagesDiffer.diff(old: self.oldMessages, new: newMessages)
                        self.oldMessages = newMessages
                        DispatchQueue.main.async {
                            completion(.init(changes: changes, allMessages: newMessages))
                        }
                        return
                    }
                    
                    self.debouncer.run {
                        let changes = MessagesDiffer.diff(old: self.oldMessages, new: newMessages)
                        self.oldMessages = newMessages
                        DispatchQueue.main.async {
                            completion(.init(changes: changes, allMessages: newMessages))
                        }
                    }
                  
					guard let session: [String: Any] = messagesDic.resolve(keyPath: "session", orDefault: [:]) as? [String: Any]  else { return }
					guard let _agent = Agent(from: session) else { return }
					DispatchQueue.main.async {
						agent(_agent)
					}
					Logger.log(event: .success, "Agent", session)
				}
			}
	}
	
	func setAttachments(for messageID: String, attachments: Attachment) {
		let uid = Auth.liveChat.currentUser?.uid ?? ""
		let ref = dataBase.reference(to: .myMessage(id: messageID, uid: uid))
		guard let type = attachments.type?.rawValue else { return }
		let json = ["attachments": [type: attachments.toJSON()]]
		ref.updateChildValues(json) { error, _ in
			if let error = error {
				Logger.logError(error)
				return
			}
		}
	}
	
	func sendOfflineMessage(_ message: OfflineMessage, customFields: [String: String]) -> Future<JSONAny?, Error> {
        var params = message.toJSON()
        params.combine(with: customFields)
		return HttpClient.shared.post(to: .offlineMessage, parameters: params)
	}
	
	func sendChatBootMessage(message: String) -> Future<JSONAny?, Error> {
		let sessionKey = Session.ID
		let langCode = Environmet.current.languageCode
		return HttpClient.shared.post(to: .chatbotMessage, parameters: ["session_key": sessionKey, "message": message, "language_code": langCode])
	}
	
	func listenFortypingEvents(from agentID: Int, completion: @escaping(Bool) -> Void) {
		
		dataBase
            .reference(withPath: "typing/\(agentID)/\(Session.ID)")
			.observe(.childAdded) { _ in
                completion(true)
			}
	}
	
	func sendTypingEvents() {
		dataBase
			.reference(withPath: "typing/\(Session.ID)")
			.childByAutoId()
			.setValue(["typing": Session.ID])
	}
    
    private func updateMessageStatus(message: Message, parentID: String) {
        Flow.async {
            if message.status == .delivered && !(UIApplication.topViewController() is ChatViewController) { return }
            if UIApplication.topViewController() is ChatViewController {
                self.updateAgentMessageStatus(newStatus: .read, messageID: message.id, agentID: parentID)
            } else {
                self.updateAgentMessageStatus(newStatus: .delivered, messageID: message.id, agentID: parentID)
            }
        }
    }
}

extension Endpoint {
	static var offlineMessage: Endpoint {
		.init(path: "/api/v1/chat/sdk/message", queryItems: [])
	}
	
	static var chatbotMessage: Endpoint {
		.init(path: "/api/v1/chatbots/create/message", queryItems: [])
	}
}

extension Dictionary {
	func logAsJson(title: String = "JSON string =") {
		do {
			let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
			if let theJSONText = String(data: jsonData, encoding: .ascii) {
				print("\(title)--------------------\n\(theJSONText)")
			}
		} catch {
			print(error.localizedDescription)
		}
	}
}

/// Run the action after delay
class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    private let queue: DispatchQueue

    init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

    func run(action: @escaping () -> Void) {
        workItem?.cancel()
        let workItem = DispatchWorkItem(block: action)
        queue.asyncAfter(deadline: .now() + delay, execute: workItem)
        self.workItem = workItem
    }
}

extension Message {
    func isValid(uid: String) -> Bool {
        toJSON(uid: uid).count >= 9
    }
}

//
//  AgentProvider.swift
//  Example
//
//  Created by Ali Ammar Hilal on 27.04.2021.
//

import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import Foundation

struct Agent: Codable {
	let id: Int
	let name: String
	let receivingStatus: Status
	let status: Status
	let avatar: String
    let ended: Bool
    
	init(
		id: Int,
		name: String,
		receivingStatus: Agent.Status,
		status: Agent.Status,
		avatar: String,
        ended: Bool
	) {
		self.id = id
		self.name = name
		self.receivingStatus = receivingStatus
		self.status = status
		self.avatar = avatar
        self.ended = ended
	}
}

extension Agent {
	init?(from json: [String: Any]) {
		guard let id: Int = json.resolve(keyPath: "receiver") else { return nil }
		let name = json.resolve(keyPath: "receiver_name", orDefault: "N/A")
		let statusString = json.resolve(keyPath: "status", orDefault: "")
		let status = Status(rawValue: statusString) ?? .offline
		let receiverStatusString = json.resolve(keyPath: "receiver_status", orDefault: "")
		let receiverStatus = Status(rawValue: receiverStatusString) ?? .offline
		let avatar = json.resolve(keyPath: "avatar", orDefault: "")
        let ended = json.resolve(keyPath: "ended", orDefault: -1)
        
        self.init(id: id, name: name, receivingStatus: receiverStatus, status: status, avatar: avatar, ended: ended == 1)
	}
}

extension Agent {
	enum Status: String, Codable {
		case online = "Online"
		case offline = "Offline"
		case active = "Active"
		case invisble
        
        var localizedValue: String {
            switch self {
            case .active: return "Active"
            case .online: return Strings.online
            case .offline: return Strings.offline
            case .invisble: return "Invisible"
            }
        }
	}
}

protocol AgentProvider {
	func checkOnlineAgent(for companyID: Int) -> Future<Bool, Error>
	func getOnlineAgentInfo(uid: String) -> Future<Agent?, Error>
    func getTheRecentMessage(uid: String) -> Future<Message?, Error>
    func getOnlineAgentCount(for companyId: Int, applicationId: Int) -> Future<Int?, Error>
}

final class AgentProviding: AgentProvider {
    
    private var databse: Database { .liveChatDB }
	
	func checkOnlineAgent(for companyID: Int) -> Future<Bool, Error> {
		let promise = Promise<Bool, Error>()
		databse
			.reference(to: .online(companyID: companyID, applicationID: 0))
			.getData { error, snapshot in
				if let error = error {
					Logger.logError(error)
					promise.fail(error: error)
				}
                guard let snapshot = snapshot else { return }
                let value = snapshot.value as? Int ?? 0
				if snapshot.exists() && value > 0 {
					promise.succeed(value: true)
				} else {
					promise.succeed(value: false)
				}
			}
		
		return promise.future
	}
	
	func getOnlineAgentInfo(uid: String) -> Future<Agent?, Error> {
		Logger.log(event: .info, "Fetching online agent")
		let promise = Promise<Agent?, Error>()
		databse
			.reference(to: .agent(uid: uid))
			.getData { (error, snapshot) in
				if let error = error {
					Logger.log(event: .error, error.localizedDescription)
					promise.fail(error: error)
					return
				}
				guard let json = snapshot?.value as? [String: Any] else {
					promise.succeed(value: nil)
					return
				}
				Logger.Log(json)
				let agent = Agent(from: json)
				promise.succeed(value: agent)
			}
		return promise.future

	}
    	
	func getOnlineAgentCount(for companyId: Int, applicationId: Int) -> Future<Int?, Error> {
		let promise = Promise<Int?, Error>()
		databse
			.reference(to: .online(companyID: companyId, applicationID: applicationId))
			.getData { error, snapshot in
				if let error = error {
					Logger.log(event: .error, error.localizedDescription)
					promise.fail(error: error)
					return
				}
				
				guard let count = snapshot?.value as? Int else {
					promise.succeed(value: nil)
					return
				}
				
				Logger.Log(count)
				promise.succeed(value: count)
				
			}
		return promise.future
	}
    
    func getTheRecentMessage(uid: String) -> Future<Message?, Error> {
        let promise = Promise<Message?, Error>()
        databse
            .reference(to: .readMessages(uid: uid))
            .getData { (error, snapshot) in
                if let error = error {
                    Logger.log(event: .error, error.localizedDescription)
                    promise.fail(error: error)
                    return
                }
                guard let messagesDic = snapshot?.value as? [String: [String: Any]] else {
                    Logger.log(event: .error, "No recent messages \(snapshot?.value)")
                    promise.succeed(value: nil)
                    return
                }
                
                var newMessages = [Message]()
                
                for message in messagesDic.map({ $0.value }) where message is [String: [String: Any]] {
                    let mssgs = message.compactMap { key, value -> [String: Any]? in
                        var _message = value as? [String: Any]
                        _message?["id"] = key
                        return _message
                    }
                    
                    mssgs.forEach { json in
                        guard let msg = Message(from: json) else { return }
                        newMessages.append(msg)
                    }
                }
                
                newMessages.sort(by: { $0.createdAt < $1.createdAt })
                promise.succeed(value: newMessages.last)
            }
        return promise.future
    }
}

//
//  FirebasePath.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 29.04.2021.
//

import Foundation

enum FirebasePath {
	case online(companyID: Int)
	case agent(uid: String)
	case readMessages(uid: String)
	case sendMessages(uid: String, childID: String)
	case myMessage(id: String, uid: String)
    case agentMessage(id: String, uid: String, agentID: String)
	
	var path: String {
		switch self {
		case .online(let companyID):
			return "count/\(companyID)/online"
		case .agent(let uid):
			return "messages/\(uid)/session"
		case .readMessages(let uid):
			return "messages/\(uid)"
		case .sendMessages(let uid, let childID):
			return "messages/\(uid)/\(uid)/\(childID)"
		case .myMessage(let id, let uid):
			return "messages/\(uid)/\(uid)/\(id)"
        case .agentMessage(let id, let uid, let agentID):
            return "messages/\(uid)/\(agentID)/\(id)"
		}
	}
}

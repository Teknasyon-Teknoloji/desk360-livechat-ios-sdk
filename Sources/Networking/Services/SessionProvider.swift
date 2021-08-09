//
//  SessionProvider.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 19.06.2021.
//

import Foundation

protocol SessionProvider {
	func terminate(sessionID: String) -> Future<JSONAny?, Error>
}

final class SessionProviding: SessionProvider {
	private let client = HttpClient.shared
	
	func terminate(sessionID: String) -> Future<JSONAny?, Error> {
		client.post(to: .session, parameters: ["session_firebase_key": sessionID])
	}
}

extension Endpoint {
	static var session: Endpoint {
		return Endpoint(
			path: "/api/v1/chat/sdk/session/ended",
			queryItems: []
		)
	}
}

//
//  LoginService.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 25.04.2021.
//

import Alamofire
import FirebaseAuth
import FirebaseCore
import Foundation

protocol LoginProvider {
	func login(using credential: Credentials, smartPlugs: SmartPlug?, path: Int?, payload: [CannedResponsePayload]?) -> Future<AuthResponse, Error>
    func authenticateSession(with token: Token) -> Future<Void, Error>
	func startChatbotMessaging()
}

final class LoginProviding: LoginProvider {
	private let client: HttpClient
	
	init(client: HttpClient) {
		self.client = client
	}
	
	func login(using credential: Credentials, smartPlugs: SmartPlug? = nil, path: Int? = nil, payload: [CannedResponsePayload]? = nil) -> Future<AuthResponse, Error> {
		var params: [String: Encodable] = ["name": credential.name, "email": credential.email, "source": "iOS"]
		
		if let smartPlugs = smartPlugs {
			params["settings"] = smartPlugs.settings
		}
		
		if let path = path {
			params["path_id"] = path
		}
		
		if let payload = payload, !payload.isEmpty {
			params["canned_response_payload"] = payload
		}
		
		if let chatbot = Storage.settings.object?.chatbot, chatbot == true {
			return client.post(to: .chatbotSession, parameters: params).mapError({
				Logger.logError($0)
				return $0
            })
		} else {
			return client.post(to: .login, parameters: params)
		}
	}
	
	func authenticateSession(with token: Token) -> Future<Void, Error> {
        Logger.Log("TOKEN \(token)")
		let promise = Promise<Void, Error>()
		Auth.liveChat.signIn(withCustomToken: token) { res, error in
			if let error = error {
				Logger.logError(error)
				promise.fail(error: error)
			}
			Logger.log(event: .success, "Firebase Session Key: \(res?.user.uid)")
			promise.succeed(value: ())
		}
		return promise.future
	}
	
	func startChatbotMessaging() {
		var params: [String: Encodable] = ["source": "iOS", "application_id": ""]

		if let appId = Storage.settings.object?.applicationID {
			params["application_id"] = appId
		}
		let _: Future<EmptyResponse, Error> = client.post(to: .chatbotMessaging, parameters: params)
	}
}

extension Endpoint {
    private static var notificationsParams: [URLQueryItem] = [
		.init(name: "source", value: "iOS"),
        .init(name: "uuid", value: Desk360LiveChat.shared.deviceID),
        .init(name: "push_token", value: Desk360LiveChat.shared.pushToken)
    ]
    
	static var login: Endpoint {
		return Endpoint(
			path: "/api/v1/chat/sdk/session",
			queryItems: notificationsParams
		)
	}
	
	static var chatbotSession: Endpoint {
		Endpoint(
			path: "/api/v1/chatbots/create/session",
			queryItems: notificationsParams
		)
	}
	
	static var chatbotMessaging: Endpoint {
		Endpoint(
			path: "/api/v1/chat/sdk/canned-response/start",
			queryItems: []
		)
	}
}

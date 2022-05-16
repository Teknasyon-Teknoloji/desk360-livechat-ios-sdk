//
//  FeedbackProvider.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 19.06.2021.
//

import Foundation

protocol FeedbackProvider {
	func rate(session: String, with status: Int) -> Future<EmptyResponse, Error>
	func send(pathId: Int, type: CannedResponseSurveyType, for payload: [CannedResponsePayload]) -> Future<BaseResponse<String?>, Error>
}

final class FeedbackProviding: FeedbackProvider {
	
	private let client = HttpClient.shared
	
	func rate(session: String, with status: Int) -> Future<EmptyResponse, Error> {
		// let promise = Promise<EmptyResponse, Error>()
		
		//	DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
		//		promise.resolve(result: .success(EmptyResponse()))
		//	}
		// return promise.future
		client.post(to: .rate, parameters: ["feedback": "\(status)", "session_firebase_key": session])
	}
	
	func send(pathId: Int, type: CannedResponseSurveyType, for payload: [CannedResponsePayload]) -> Future<BaseResponse<String?>, Error> {
		client.post(to: .rate, parameters: [
			"path_id": pathId,
			"feedback": type.rawValue,
			"canned_response_payload": payload,
			"source": "iOS"
		])
	}
}

extension Endpoint {
	static var rate: Endpoint {
		Endpoint(
			path: "/api/v1/chat/sdk/feedback",
			queryItems: []
		)
	}
}

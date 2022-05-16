//
//  SettingsService.swift
//  Example
//
//  Created by Ali Ammar Hilal on 22.04.2021.
//

import Foundation

protocol SettingsProvider {
	func getSettings(language: String) -> Future<Settings, Error>
}

final class SettingsProviding: SettingsProvider {
	private let client: HttpClient
	
	init(client: HttpClient = .shared) {
		self.client = client
	}
	
	func getSettings(language: String) -> Future<Settings, Error> {
        return client.get(from: .settings(language: language.lowercased()), parameters: [:])
	}
	
}

extension Endpoint {
	static func settings(language: String) -> Endpoint {
		return Endpoint(
			path: "/api/v1/chat/sdk/setting",
			queryItems: [
				URLQueryItem(name: "language", value: language),
				URLQueryItem(name: "source", value: "iOS")
			]
		)
	}
}

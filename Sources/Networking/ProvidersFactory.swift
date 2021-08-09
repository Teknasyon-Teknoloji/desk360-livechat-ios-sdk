//
//  ProvidersFactory.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 26.04.2021.
//

import Foundation

final class ProvidersFactory {
	private let client = HttpClient.shared
	
	func makeSettingsProvider() -> SettingsProvider {
		SettingsProviding(client: client)
	}
	
	func makeLoginProvider() -> LoginProvider {
		LoginProviding(client: client)
	}
	
	func makeAgentProvider() -> AgentProvider {
		AgentProviding()
	}
	
	func makeMessagingProvider() -> MessagingProvider {
		MessagingProviding()
	}
	
	func makeFileUploader() -> FileUploader {
		FileUploading()
	}
	
	func makeSessionProvider() -> SessionProvider {
		SessionProviding()
	}
	
	func makeFeedbackProvider() -> FeedbackProvider {
		FeedbackProviding()
	}
}

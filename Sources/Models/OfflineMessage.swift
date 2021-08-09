//
//  OfflineMessage.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 16.06.2021.
//

import Foundation

struct OfflineMessage {
	
	let name: String
	let email: String
	let message: String
	
	func toJSON() -> [String: String] {
		[
			"name": name,
			"email": email,
			"message": message,
			"source": "iOS"
		]
	}
}

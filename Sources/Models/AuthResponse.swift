//
//  AuthResponse.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 25.04.2021.
//

import Foundation

typealias Token = String

struct AuthResponse: Codable {
	let token: Token
}

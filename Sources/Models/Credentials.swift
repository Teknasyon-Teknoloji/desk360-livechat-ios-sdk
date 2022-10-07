//
//  Credentials.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 25.04.2021.
//

import Foundation

/// The credentials of the user
@objc public class Credentials: NSObject, Codable {
	
	/// User name
	public let name: String
	
	/// User email
	public let email: String
	
	/// Intilaize the object with the given parameters
	/// - Parameters:
	///   - name: The user name.
	///   - email: The user email.
    @objc public init(name: String, email: String) {
		self.name = name
		self.email = email
	}
}

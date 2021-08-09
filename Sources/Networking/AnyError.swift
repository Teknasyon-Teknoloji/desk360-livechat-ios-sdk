//
//  AnyError.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 22.04.2021.
//

import Foundation

struct AnyError: Error, LocalizedError {
	let message: String?
	
	var errorDescription: String? {
		message
	}
}

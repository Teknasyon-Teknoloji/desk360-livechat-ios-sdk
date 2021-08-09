//
//  BaseResponse.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 31.05.2021.
//

import Foundation

struct BaseResponse<Wrapped: Codable>: Codable {
	let meta: Meta?
	let data: Wrapped?
}

// MARK: - Meta
struct Meta: Codable {
	let success: Bool?
	let message: String?
}

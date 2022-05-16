//
//  CannedResponsePathCollector.swift
//  Desk360LiveChat
//
//  Created by Alper Tabak on 15.03.2022.
//

import Foundation

internal struct CannedResponsePayload: Encodable {
	let id: Int
	let date: Double
}

internal struct CannedResponsePathCollector {
	
	private var paths: [CannedResponsePayload] = []
	
	mutating func append(_ path: ResponseElement) {
		let date = Double(Date().timeIntervalSince1970)
		let payload = CannedResponsePayload(id: path.id, date: date)
		self.paths.append(payload)
	}
	
	mutating func reset() {
		self.paths.removeAll()
	}
	
	func getPayload() -> [CannedResponsePayload] {
		return self.paths
	}
	
}

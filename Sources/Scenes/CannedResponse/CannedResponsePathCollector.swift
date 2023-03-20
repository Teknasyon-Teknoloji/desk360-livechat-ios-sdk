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
	static var shared = CannedResponsePathCollector()

	private var paths: [CannedResponsePayload] = []

	func append(_ path: ResponseElement) {
		let date = Double(Date().timeIntervalSince1970)
		let payload = CannedResponsePayload(id: path.id, date: date)
		Self.shared.paths.append(payload)
	}

	func reset() {
		Self.shared.paths.removeAll()
	}

	func getPayload() -> [CannedResponsePayload] {
		return Self.shared.paths
	}
}

//
//  SmartPlug.swift
//  Desk360LiveChat
//
//  Created by Alper Tabak on 16.12.2021.
//

import Foundation

public typealias SmartPlugType = [String: Codable]

public struct SmartPlug: Codable {
	
	var settings: [String: EncodableValue]
	
	public init(_ settings: SmartPlugType) {
		var holder: [String: EncodableValue] = [:]
		
		for (key, value) in settings {
			holder[key] = EncodableValue(value)
		}
		self.settings = holder
		
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.settings, forKey: .settings)
	}
	
	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		if values.contains(.settings), let jsonData = try? values.decode(Data.self, forKey: .settings) {
			settings = (try? JSONSerialization.jsonObject(with: jsonData) as? [String: EncodableValue]) ??  [String: EncodableValue]()
		} else {
			settings = [String: EncodableValue]()
		}
	}
	
	enum CodingKeys: String, CodingKey {
		case settings
	}
	
}

internal struct EncodableValue: Encodable {
	let value: Encodable

	public init(_ v: Encodable) {
		self.value = v
	}
	
	public func encode(to encoder: Encoder) throws {
		try value.encode(to: encoder)
	}
	
}

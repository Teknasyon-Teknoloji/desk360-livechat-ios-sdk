//
//  Environment.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 22.04.2021.
//

import Foundation

final class Environmet {
	static let current = Environmet()
	
	var type: EnvironmentType {
		#if DEBUG
		return .stage
		#else
		return .production
		#endif
	}
	
	var baseURL: String {
        Storage.host.object ?? ""
	}
	
	var languageCode: String {
        Storage.langaugeCode.object ?? Locale.current.languageCode ?? "en"
	}
	
	enum EnvironmentType {
		case production
		case stage
	}
}

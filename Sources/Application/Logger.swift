//
//  Logger.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 22.04.2021.
//

import Foundation

struct Logger {
	static func log(
		event: Event,
		_ messages: Any...,
		in file: StaticString = #filePath,
		line: UInt = #line
	) {
        if CommandLine.arguments.contains("ENABLE_DESK360_LIVE_CHAT_LOG") {
            let fileName = String(describing: file).components(separatedBy: "/").last ?? String(describing: file)
            let timePrefix = Date.nowString()
            
            print(event.icon + " " + timePrefix + " ", messages.count == 1 ? messages[0] : messages, "in file: \(fileName)", "at line: \(line)")
        }
	}
	
	static func Log(
		_ messages: Any...,
		in file: StaticString = #filePath,
		line: UInt = #line
	) {
		log(event: .info, messages, in: file, line: line)
	}
	
	static func logError(
		_ error: Error,
		in file: StaticString = #filePath,
		line: UInt = #line
	) {
		log(event: .error, error.localizedDescription, in: file, line: line)
	}
	
	enum Event {
		case success
		case info
		case error
	}
}

extension Logger.Event {
	var icon: String {
		switch self {
		case .error:
			return "❌"
		case .info:
			return "⚙️"
		case .success:
			return "✅"
		}
	}
}

fileprivate extension Date {
	static func nowString() -> String {
		MessageDateFormatter.shared.string(from: Date(), showsFullDate: true)
	}
}

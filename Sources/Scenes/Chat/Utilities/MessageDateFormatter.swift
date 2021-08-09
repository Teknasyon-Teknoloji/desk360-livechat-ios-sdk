//
//  MessageDateFormatter.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 4.05.2021.
//

import Foundation

/// A helper class to format each message date this will help us
/// reducing the memory footprint when we loop over the fetched
/// messages.
class MessageDateFormatter {

	// MARK: - Properties
	static let shared = MessageDateFormatter()

	private let formatter = DateFormatter()

	// MARK: - Methods
	func string(from date: Date, showsFullDate: Bool = false) -> String {
		configureDateFormatter(for: date, showsFullDate: showsFullDate)
		return formatter.string(from: date)
	}
	
	func dateForHeader(from date: Date) -> String {
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter.string(from: date)
	}
    
    func onlyHourString(from date: Date) -> String {
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
	
	func attributedString(from date: Date, with attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
		let dateString = string(from: date)
		return NSAttributedString(string: dateString, attributes: attributes)
	}

	func configureDateFormatter(for date: Date, showsFullDate: Bool = false) {
		guard !showsFullDate else {
			formatter.dateFormat = "MMM d, yyyy, h:mm:ss a"
			return
		}
		
		switch true {
		case Calendar.current.isDateInToday(date) || Calendar.current.isDateInYesterday(date):
			formatter.doesRelativeDateFormatting = true
			formatter.dateStyle = .short
			formatter.timeStyle = .short
		case Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear):
			formatter.dateFormat = "EEEE h:mm a"
		case Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year):
			formatter.dateFormat = "E, d MMM, h:mm a"
		default:
			formatter.dateFormat = "MMM d, yyyy, h:mm a"
		}
	}
	
	func date(from string: String) -> Date {
		formatter.dateFormat = "yyyy-MM-ddHH:mm:ss.SSS"
		return formatter.date(from: string) ?? Date()
	}
    
    func date(from timeInterval: TimeInterval) -> Date {
        Date(milliseconds: timeInterval)
    }
}

extension Date {
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds: TimeInterval) {
        self = Date(timeIntervalSince1970: milliseconds / 1000)
    }
}

//
//  String+Extensions.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 22.04.2021.
//

import Foundation
import UIKit

extension NSAttributedString {
	
	public convenience init?(HTMLString html: String, font: UIFont? = nil) throws {
		let options : [NSAttributedString.DocumentReadingOptionKey : Any] =
			[ .documentType: NSAttributedString.DocumentType.html,
               .characterEncoding: String.Encoding.utf8.rawValue
            ]

		guard let data = html.data(using: .utf8) else {
			throw NSError(domain: "Parse Error", code: 0, userInfo: nil)
		}

		if let font = font {
			guard let attr = try? NSMutableAttributedString(
				data: data,
				options: options,
				documentAttributes: nil
			) else {
				throw NSError(domain: "Parse Error", code: 0, userInfo: nil)
			}
			/*var attrs = attr.attributes(at: 0, effectiveRange: nil)
			attrs[NSAttributedString.Key.font] = font
			attr.setAttributes(attrs, range: NSRange(location: 0, length: attr.length))*/
                        
            let textRangeForFont : NSRange = NSMakeRange(0, attr.length)
            attr.addAttributes([NSAttributedString.Key.font : font], range: textRangeForFont)
            
			self.init(attributedString: attr)
		} else {
			try? self.init(data: data, options: options, documentAttributes: nil)
		}
	}
}

extension String {
    var uiColor: UIColor? {
        UIColor(hex: self)
    }

	var htmlToAttributedString: NSAttributedString? {
		guard let data = data(using: .utf8) else { return nil }
		do {
			
			let attrString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
			
			return attrString
		} catch {
			return nil
		}
	}
	
	func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
		let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [
			.font: font
		], context: nil)

		return ceil(boundingBox.width)
	}
    
    func size(constraintedWidth width: CGFloat) -> CGSize {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = self
        label.font = FontFamily.Gotham.book.font(size: 16)
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label.frame.size
    }
    
    func trim() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func condenseWhitespace() -> String {
        let components = components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}

extension Sequence where Element: Equatable {
    func grouped(byDate dateKey: (Element) -> Date, ascending: Bool = true) -> [[Element]] {
        var categories: [[Element]] = []
        for element in self {
            let key = dateKey(element)
            guard let dayIndex = categories.firstIndex(where: { $0.contains(where: { Calendar.current.isDate(dateKey($0), inSameDayAs: key) }) }) else {
                guard let nextIndex = categories.firstIndex(where: { $0.contains(where: { dateKey($0).compare(key) == (ascending ? .orderedDescending : .orderedAscending) }) }) else {
                    categories.append([element])
                    continue
                }
                categories.insert([element], at: nextIndex)
                continue
            }
            
            guard let nextIndex = categories[dayIndex].firstIndex(where: { dateKey($0).compare(key) == (ascending ? .orderedDescending : .orderedAscending) }) else {
                categories[dayIndex].append(element)
                continue
            }
            categories[dayIndex].insert(element, at: nextIndex)
        }
        return categories
    }
}

extension Array {
    func sliced(by dateComponents: Set<Calendar.Component>, for key: KeyPath<Element, Date>) -> [Date: [Element]] {
        let initial: [Date: [Element]] = [:]
        let groupedByDateComponents = reduce(into: initial) { acc, cur in
            let components = Calendar.current.dateComponents(dateComponents, from: cur[keyPath: key])
            let date = Calendar.current.date(from: components)!
            let existing = acc[date] ?? []
            acc[date] = existing + [cur]
        }
        
        return groupedByDateComponents
    }
}

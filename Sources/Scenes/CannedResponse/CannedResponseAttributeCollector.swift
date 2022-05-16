//
//  CannedResponseAttributeCollector.swift
//  Desk360LiveChat
//
//  Created by Alper Tabak on 25.04.2022.
//

import Foundation

internal struct CannedResponseAttribute {
	let id: Int
	let attribute: NSAttributedString
}

internal struct CannedResponseAttributeCollector {
	
	static var shared = CannedResponseAttributeCollector()
	
	private init() {
		
	}
	
	var attributes: [CannedResponseAttribute] = []
	
	public mutating func collectData(for response: [CannedResponse]) {
		response.forEach { elements in
			guard let grouped = elements.groupedUnits else { return }
			let element = grouped.getElements()
			self.append(contentsOf: element)
		}
	}
	
	mutating func append(_ path: ResponseElement) {
		guard path.type == .message else { return }
        
        guard let attribute = try? NSAttributedString(HTMLString: path.content, font: FontFamily.Gotham.book.font(size: 16) ?? .systemFont(ofSize: 17)) else {
            return
        }
        
		let payload = CannedResponseAttribute(id: path.id, attribute: attribute)
		self.attributes.append(payload)
	}
	
	mutating func append(contentsOf elements: [ResponseElement]) {
		elements.forEach { element in
			self.append(element)
		}
	}
	
	mutating func reset() {
		self.attributes.removeAll()
	}
	
	func attribute(for id: Int) -> CannedResponseAttribute? {
		return self.attributes.first(where: { $0.id == id } )
	}
	
}

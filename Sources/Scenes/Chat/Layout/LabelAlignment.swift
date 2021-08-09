//
//  LabelAlignment.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 13.05.2021.
//

import UIKit

struct LabelAlignment: Equatable {

	var alignment: Alignment
	var textInsets: UIEdgeInsets
	
	init(alignment: Alignment, textInsets: UIEdgeInsets) {
		self.alignment = alignment
		self.textInsets = textInsets
	}

}

// MARK: - Equatable Conformance
extension LabelAlignment {

	static func == (lhs: LabelAlignment, rhs: LabelAlignment) -> Bool {
		return lhs.alignment == rhs.alignment && lhs.textInsets == rhs.textInsets
	}

}

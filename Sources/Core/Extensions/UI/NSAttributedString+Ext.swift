//
//  NSAttributedString+Ext.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 4.05.2021.
//

import Foundation
import UIKit

extension NSAttributedString {

	func width(considering height: CGFloat) -> CGFloat {

		let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: height)
		let rect = self.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
		return rect.width
		
	}
}

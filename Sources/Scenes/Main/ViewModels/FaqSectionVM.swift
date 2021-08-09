//
//  FaqSectionVM.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 27.04.2021.
//

import Foundation

final class FaqSectionVM {
	let faq: Faq
	var isExpanded: Bool
	
	init(faq: Faq, isExpanded: Bool = false) {
		self.faq = faq
		self.isExpanded = isExpanded
	}
}

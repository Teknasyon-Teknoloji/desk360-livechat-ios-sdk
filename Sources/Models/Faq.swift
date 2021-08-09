//
//  Faq.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 27.04.2021.
//

import Foundation

struct Faq {
	let title: String
	let description: String
}

#if DEBUG
extension Faq {
	static let fake1 = "Pellentesque nulla nec dolor cursus, non porta ante finibus. Vestibulum in lectus a Nunc condimentum euismod consequat. Nam placerat pharetra nibh."
	static let fake2 = "Vestibulum in lectus a erat tempor ultrices.Vestibulum pellentesque nulla nec dolor cursus, non porta ante finibus. Nunc Nam placerat pharetra nibh. Vestibulum in lectus a erat ultrices (...)"
	
	static let support = Faq(title: "How to get support?", description: fake1)
	static let messages = Faq(title: "How to chat?", description: fake1 + fake2)
	static let register = Faq(title: "How to register?", description: fake2)
	
}
#endif

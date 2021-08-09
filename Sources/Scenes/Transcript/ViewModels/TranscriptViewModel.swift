//
//  TranscriptViewModel.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 19.06.2021.
//

import Foundation

final class TranscriptViewModel {
	weak private var router: Coordinator<MainRoute>?
	
	init(router: Coordinator<MainRoute>?) {
		self.router = router
	}
	
	func backToMain() {
		router?.trigger(.popToRoot)
	}
	
	func back() {
		router?.trigger(.pop)
	}
}

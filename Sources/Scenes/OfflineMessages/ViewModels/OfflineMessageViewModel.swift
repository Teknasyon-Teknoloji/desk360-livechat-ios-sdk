//
//  OfflineMessageViewModel.swift
//  Example
//
//  Created by Ali Ammar Hilal on 17.06.2021.
//

import Foundation

final class OfflineMessageViewModel {
	
	weak private var router: Coordinator<MainRoute>?
	
	init(
		router: Coordinator<MainRoute>?
	) {
		self.router = router
	}
	
	func backToRoot() {
		router?.trigger(.popToRoot)
	}
}

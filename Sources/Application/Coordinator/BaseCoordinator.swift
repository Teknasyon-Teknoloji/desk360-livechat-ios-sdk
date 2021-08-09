//
//  Coordinator.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 26.04.2021.
//

import Foundation
import UIKit

protocol BaseCoordinatorType: AnyObject {
	associatedtype Route
	func start()
	func trigger(_ route: Route?)
}

protocol PresentableCoordinatorType: BaseCoordinatorType, Presentable {}

class PresentableCoordinator<Route>: NSObject, PresentableCoordinatorType {
	
	override init() {
		super.init()
	}
	
	func start() { trigger(nil) }
	func trigger(_ route: Route?) {}

	func asPresentable() -> UIViewController {
		fatalError("Must override asPresentable()")
	}
}

protocol CoordinatorType: PresentableCoordinatorType {
	var router: RouterType { get }
}

class Coordinator<Route>: PresentableCoordinator<Route>, CoordinatorType {
	
	var childCoordinators: [Coordinator<Route>] = []
	
	var router: RouterType
	
	init(router: RouterType) {
		self.router = router
		super.init()
	}
	
	func addChild(_ coordinator: Coordinator<Route>) {
		childCoordinators.append(coordinator)
	}
	
	func removeChild(_ coordinator: Coordinator<Route>?) {
		
		if let coordinator = coordinator, let index = childCoordinators.firstIndex(of: coordinator) {
			childCoordinators.remove(at: index)
		}
	}
	
	override func asPresentable() -> UIViewController {
		return router.asPresentable()
	}
}

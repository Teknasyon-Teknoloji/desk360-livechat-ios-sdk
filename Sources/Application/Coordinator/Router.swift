//
//  Router.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 26.04.2021.
//

import Foundation
import UIKit

protocol Route {}

protocol RouterType: AnyObject, Presentable {
	var navigationController: UINavigationController { get }
	var rootViewController: UIViewController? { get }
	func present(_ module: Presentable, animated: Bool)
	func dismiss(animated: Bool, completion: (() -> Void)?)
	func push(_ module: Presentable, animated: Bool, completion: (() -> Void)?)
	func popModule(animated: Bool)
	func setRootModule(_ module: Presentable, hideBar: Bool)
	func popToRootModule(animated: Bool)
}

final class Router: NSObject, RouterType {
	
	private var completions: [UIViewController : () -> Void]
	
	var rootViewController: UIViewController? {
		return navigationController.viewControllers.first
	}
	
	var hasRootController: Bool {
		return rootViewController != nil
		
	}
	
	let navigationController: UINavigationController
	
	init(navigationController: UINavigationController = UINavigationController()) {
		self.navigationController = navigationController
		self.completions = [:]
		super.init()
		self.navigationController.delegate = self
	}
	
	func present(_ module: Presentable, animated: Bool = true) {
		navigationController.present(module.asPresentable(), animated: animated, completion: nil)
	}
	
	func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
		navigationController.dismiss(animated: animated, completion: completion)
	}
	
	func push(_ module: Presentable, animated: Bool = true, completion: (() -> Void)? = nil) {
		
		let controller = module.asPresentable()
		
		// Avoid pushing UINavigationController onto stack
		guard controller is UINavigationController == false else {
			return
		}
		
		if let completion = completion {
			completions[controller] = completion
		}
		
		navigationController.pushViewController(controller, animated: animated)
	}
	
	func popModule(animated: Bool = true) {
		if let controller = navigationController.popViewController(animated: animated) {
			runCompletion(for: controller)
		}
	}
	
	func setRootModule(_ module: Presentable, hideBar: Bool = false) {
		// Call all completions so all coordinators can be deallocated
		completions.forEach { $0.value() }
		// Then remove all the completions to prevent potental memeory leaks
		// last revised 27.4.2021
		completions.removeAll()
		navigationController.setViewControllers([module.asPresentable()], animated: false)
		navigationController.isNavigationBarHidden = hideBar
	}
	
	func popToRootModule(animated: Bool) {
		if let controllers = navigationController.popToRootViewController(animated: animated) {
			controllers.forEach { runCompletion(for: $0) }
		}
	}
	
	fileprivate func runCompletion(for controller: UIViewController) {
		guard let completion = completions[controller] else { return }
		completion()
		completions.removeValue(forKey: controller)
	}
}

// MARK: Presentable
extension Router {
	func asPresentable() -> UIViewController {
		return navigationController
	}
}

// MARK: UINavigationControllerDelegate
extension Router: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		
		// Ensure the view controller is popping
		guard let poppedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
			!navigationController.viewControllers.contains(poppedViewController) else {
			return
		}

		runCompletion(for: poppedViewController)
	}
}

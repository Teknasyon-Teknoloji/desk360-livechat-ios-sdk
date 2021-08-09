//
//  Presentable.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 26.04.2021.
//

import UIKit

protocol Presentable {
	func asPresentable() -> UIViewController
}

extension UIViewController: Presentable {
	func asPresentable() -> UIViewController {
		return self
	}
}

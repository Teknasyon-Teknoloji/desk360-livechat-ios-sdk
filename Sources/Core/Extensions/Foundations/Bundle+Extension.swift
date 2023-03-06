//
//  Bundle+Extension.swift
//  Example
//
//  Created by Ali Ammar Hilal on 14.04.2021.
//

import Foundation

extension Bundle {

	#if IS_SPM
	static var sdkBundle: Bundle = Bundle.module
	#else
	static var sdkBundle: Bundle {
		return Bundle(for: MainViewController.self)
	}
	#endif
	
	static var assetsBundle: Bundle? {
		let frameworkBundle = Bundle(for: Desk360LiveChat.self)
		guard let resourceBundleUrl = frameworkBundle.url(forResource: "Desk360LiveChatAssets", withExtension: "bundle") else {
			return nil
		}
		
		guard let resourceBundle = Bundle(url: resourceBundleUrl) else { return nil }
		return resourceBundle
	}

	static var localizedBundle: Bundle? {
		let bundle = Bundle(for: MainView.self)
		guard let path = bundle.path(forResource: "LiveChat", ofType: "bundle") else { return nil }
		guard let localizedBundle = Bundle(path: path) else { return nil }
		return localizedBundle
	}

	static var base: Bundle? {
		let bundle = Bundle(identifier: "test")
		guard let resourceBundleUrl = bundle?.url(forResource: "LiveChat", withExtension: "lproj") else { return nil }
		guard let resourceBundle = Bundle(url: resourceBundleUrl) else { return nil }
		return resourceBundle
	}
}

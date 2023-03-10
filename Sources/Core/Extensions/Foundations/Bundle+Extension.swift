//
//  Bundle+Extension.swift
//  Example
//
//  Created by Ali Ammar Hilal on 14.04.2021.
//

import Foundation

extension Bundle {
	static var assetsBundle: Bundle? {
        let frameworkBundle = Bundle(for: MainViewController.self)
        
        #if SWIFT_PACKAGE
        guard let path = frameworkBundle.url(forResource: "Desk360LiveChat_Desk360LiveChat", withExtension: "bundle")?.absoluteString else { return nil }
            let resourceBundleUrl = URL(string: path + "Desk360LiveChatAssets.bundle")
        #else
            let resourceBundleUrl = frameworkBundle.url(forResource: "Desk360LiveChatAssets", withExtension: "bundle")
        #endif
        
		guard let resourceBundleUrl, let resourceBundle = Bundle(url: resourceBundleUrl) else { return nil }
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

//
//  ViewController.swift
//  Example
//
//  Created by Ali Hilal on 12 Apr 2021.
//  Copyright © 2021 Teknasyon. All rights reserved.
//

import UIKit
import Desk360LiveChat

// MARK: - ViewController

/// The ViewController
class ViewController: UIViewController {

    // MARK: Properties
    
    /// The Label
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "🚀\nDesk360LiveChat\nExample"
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
		label.isUserInteractionEnabled = true
        return label
    }()
    
    // MARK: View-Lifecyclee
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
		let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		self.label.addGestureRecognizer(gesture)
    }
    
    /// LoadView
    override func loadView() {
        self.view = self.label
    }
	
	@objc private func handleTap() {
		let apiKey = "APIKey"
		let cred = Credentials(
			name: "Test",
			email: "test@test.com"
		)
		
		let host = "yourapp.desk360.com"
		guard let uuid = UIDevice.current.identifierForVendor?.uuidString else { return }
		
		let keyValues: SmartPlugType = [
			"key1": 15,
			"key2": true,
			"key3": [1,2,3,4],
			"key4": ["a","b","c"],
			"key5": ["key6": 0]
		]
		
		let smartPlug = SmartPlug(keyValues)
		
		let properties = LiveChatProperties(
			appKey: apiKey,
			host: host,
			deviceID: uuid,
			loginCredentials: cred,
			smartPlug: smartPlug
		)
		
		Desk360LiveChat.shared.start(using: properties, on: self)
	}
}

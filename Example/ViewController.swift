//
//  ViewController.swift
//  Example
//
//  Created by Ali Hilal on 12 Apr 2021.
//  Copyright © 2021 Teknasyon. All rights reserved.
//

import UIKit
import LiveChat

// MARK: - ViewController

/// The ViewController
class ViewController: UIViewController {

    // MARK: Properties
    
    /// The Label
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "🚀\nLiveChat\nExample"
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    // MARK: View-Lifecyclee
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			let apiKey = "YOUR_API_KEY_HERE"
			let cred = Credentials(
				name: "Test",
				email: "test@test.com"
			)
			
			let host = "yourapp.desk360.com"
			Desk360LiveChat.shared.start(appKey: apiKey, host: host, using: cred, on: self)
		}
    }
    
    /// LoadView
    override func loadView() {
        self.view = self.label
    }
}

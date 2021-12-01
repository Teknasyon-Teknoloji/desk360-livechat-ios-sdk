//
//  BaseViewController.swift
//  Example
//
//  Created by Ali Ammar Hilal on 14.06.2021.
//

import UIKit

class BaseViewController: UIViewController, AlertShowing {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupAppearnace()
		bindViewModel()
		bindUIControls()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		.lightContent
	}
	
    override var prefersStatusBarHidden: Bool {
        false
    }
    
	func setupAppearnace() {
		UIApplication.shared.statusBarUIView?.backgroundColor = config?.general.backgroundHeaderColor.uiColor
		view.backgroundColor = config?.general.backgroundMainColor.uiColor
        navigationController?.navigationBar.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
	}
	
	func bindUIControls() {
		
	}
	
	func bindViewModel() {
		
	}
	
	func render(state: State, delay: TimeInterval = 0) {
		DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if let aView = self.view as? Loadingable {
                aView.setLoading(false)
            }
			switch state {
			case .loading, .uploading:
				if let aView = self.view as? Loadingable {
					aView.setLoading(true)
				}
			case .showingData:
				if let aView = self.view as? Loadingable {
					aView.setLoading(false)
				}
			case .error(let error):
				Logger.logError(error)
			}
		}
	}
}

extension BaseViewController {
	enum State {
		case loading
		case showingData
		case uploading
		case error(Error)
	}
}

//
//  VideoPlayer.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 21.06.2021.
//

import UIKit

class VGVerticalViewController: UIViewController {
	let player: VGPlayer
	let url: URL
	
	init(url: URL) {
		self.url = url
		player = VGPlayer(URL: url)
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.insetsLayoutMarginsFromSafeArea = false
		
		UIApplication.shared.statusBarUIView?.backgroundColor = .black
		UIApplication.shared.statusBarUIView?.isHidden = true
		
		player.delegate = self
		
		view.addSubview(player.displayView)
		player.backgroundMode = .proceed
		player.play()
		player.displayView.delegate = self
		player.displayView.titleLabel.text = ""

		player.displayView.fillSuperview()
		
	}

//	override var preferredStatusBarStyle: UIStatusBarStyle {
//		.default
//	}
//
//	override var prefersStatusBarHidden: Bool {
//		true
//	}
//
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: true)

        // UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		// self.navigationController?.setNavigationBarHidden(false, animated: true)
		// UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
        UIApplication.shared.statusBarUIView?.isHidden = false
        UIApplication.shared.statusBarUIView?.backgroundColor = config?.general.backgroundHeaderColor.uiColor
        
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		// UIApplication.shared.setStatusBarHidden(false, with: .none)
		// UIApplication.shared.keyWindow?.windowLevel = UIWindow.Level.statusBar
        UIApplication.shared.statusBarUIView?.backgroundColor = config?.general.backgroundHeaderColor.uiColor
	}
}

extension VGVerticalViewController: VGPlayerDelegate {
	func vgPlayer(_ player: VGPlayer, playerFailed error: VGPlayerError) {
		print(error)
	}
	
	func vgPlayer(_ player: VGPlayer, stateDidChange state: VGPlayerState) {
		print("player State ", state)
	}
	
	func vgPlayer(_ player: VGPlayer, bufferStateDidChange state: VGPlayerBufferstate) {
		print("buffer State", state)
	}
	
}

extension VGVerticalViewController: VGPlayerViewDelegate {
	func vgPlayerView(_ playerView: VGPlayerView, willFullscreen fullscreen: Bool) {
		
	}
	
	func vgPlayerView(didTappedClose playerView: VGPlayerView) {
		if playerView.isFullScreen {
			playerView.exitFullscreen()
		} else {
			self.navigationController?.popViewController(animated: true)
		}
		
	}
	
	func vgPlayerView(didDisplayControl playerView: VGPlayerView) {
		// UIApplication.shared.keyWindow?.windowLevel = UIWindow.Level.normal
		UIApplication.shared.isStatusBarHidden = !playerView.isDisplayControl
	}
}

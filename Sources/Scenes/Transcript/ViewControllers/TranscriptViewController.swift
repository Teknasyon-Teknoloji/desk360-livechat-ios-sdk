//
//  TranscriptViewController.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 19.06.2021.
//

import Foundation

final class TranscriptViewController: BaseViewController, Layouting, ViewModelIntializing {
	
	typealias ViewType = TranscriptView
	typealias ViewModel = TranscriptViewModel
	
	let viewModel: TranscriptViewModel
	
	init(viewModel: TranscriptViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = ViewType.create()
	}
	
	override func bindViewModel() {
		super.bindViewModel()
		
	}
	
	override func bindUIControls() {
		super.bindUIControls()
		layoutableView.agentView.backButton.action = viewModel.back
		layoutableView.backButton.addTarget(self, action: #selector(goToChatButttonTapped), for: .touchUpInside)
		layoutableView.closeChatButton.addTarget(self, action: #selector(closeChatButtonTapped), for: .touchUpInside)
	}
}

private extension TranscriptViewController {
	@objc func closeChatButtonTapped() {
		viewModel.backToMain()
	}
	
	@objc func goToChatButttonTapped() {
		viewModel.back()
	}
}

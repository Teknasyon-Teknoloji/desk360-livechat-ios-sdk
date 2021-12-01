//
//  OfflineMessageViewController.swift
//  Example
//
//  Created by Ali Ammar Hilal on 17.06.2021.
//

import UIKit

final class OfflineMessageViewController: BaseViewController, Layouting, ViewModelIntializing {
	typealias ViewType = OfflineMessageView
	typealias ViewModel = OfflineMessageViewModel

	let viewModel: OfflineMessageViewModel
	
	init(viewModel: OfflineMessageViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func loadView() {
		view = ViewType.create()
	}
	
	override func setupAppearnace() {
		super.setupAppearnace()
        layoutableView.agentView.optionsButton.isHidden = true
        layoutableView.agentView.configure(with: nil)
        layoutableView.backgroundColor = .white
	}
	
	override func bindViewModel() {
		super.bindViewModel()
		layoutableView.closeChatButton.action = viewModel.backToRoot
	}
    
    override func bindUIControls() {
        super.bindUIControls()
        layoutableView.agentView.backButton.action = viewModel.backToRoot
    }
}

// MARK: - Actions
private extension OfflineMessageViewController {
    @objc func didTapBackButton() {
        viewModel.backToRoot()
    }
}

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
	
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//		navigationController?.navigationBar.isHidden = false
//		navigationController?.setNavigationBarHidden(false, animated: true)
//	}
//	
//	override func viewWillDisappear(_ animated: Bool) {
//		super.viewWillDisappear(animated)
//		navigationController?.navigationBar.isHidden = true
//		navigationController?.setNavigationBarHidden(true, animated: true)
//	}
	
	override func setupAppearnace() {
		super.setupAppearnace()
        layoutableView.agentView.optionsButton.isHidden = true
        layoutableView.agentView.configure(with: nil)
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

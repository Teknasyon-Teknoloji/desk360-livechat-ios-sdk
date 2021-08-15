//
//  SessionTerminationViewController.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 18.06.2021.
//

import UIKit

final class SessionTerminationViewController: BaseViewController, ViewModelIntializing, Layouting {
	
	typealias ViewModel = SessionTerminationViewModel
	typealias ViewType = SessionTerminationView
	
	var viewModel: SessionTerminationViewModel
	
	init(viewModel: SessionTerminationViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func loadView() {
		view = ViewType.create()
	}
	
	override func bindViewModel() {
		super.bindViewModel()
		layoutableView.agentView.configure(with: nil)
		layoutableView.agentView.backButton.action = viewModel.backToRoot
		
		viewModel.statusHandler = { [weak self] newStatus in
			self?.render(state: newStatus)
		}
	}
	
	override func bindUIControls() {
		super.bindUIControls()
		layoutableView.transcriptButton.addTarget(self, action: #selector(transcriptButtonTapped), for: .touchUpInside)
		layoutableView.likeButton.addTarget(self, action: #selector(ratingButtonTapped), for: .touchUpInside)
		layoutableView.dislikeButton.addTarget(self, action: #selector(ratingButtonTapped), for: .touchUpInside)
		layoutableView.startNewChatButton.action = viewModel.startNewChat

	}
    
    override func setupAppearnace() {
        super.setupAppearnace()
        layoutableView.backgroundColor = .white
    }
}

private extension SessionTerminationViewController {
	@objc func transcriptButtonTapped() {
		viewModel.prepareTranscript()
	}
	
	@objc func ratingButtonTapped(_ sender: UIButton) {
		let rating: Rating = sender == layoutableView.likeButton ? .like : .dislike
		layoutableView.animateRating(tappedButton: sender)
		viewModel.rate(with: rating)
			.on(
				success: { _ in
					self.render(state: .showingData)
				},
				failure: { error in
					Logger.Log(error)
					self.render(state: .error(error))
				}
			)
	}
}

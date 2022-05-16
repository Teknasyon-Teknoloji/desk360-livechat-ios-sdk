//
//  MainViewController.swift
//  Example
//
//  Created by Ali Ammar Hilal on 12.04.2021.
//

import UIKit

enum State<Result> {
	case success(Result)
	case failure(Error)
	case empty
}

final class MainViewController: BaseViewController, ViewModelIntializing, Layouting {
	typealias ViewType  = MainView
	typealias ViewModel = MainViewModel
	
	let viewModel: ViewModel
	
//	var sections: [FaqSectionVM] = [
//		.init(faq: .support),
//		.init(faq: .support),
//		.init(faq: .register),
//		.init(faq: .messages)
//	]
	
	override func loadView() {
		view = ViewType.create()
	}
	
	required init(viewModel: ViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	@available(*, unavailable, message: "init(coder:) has not been implemented")
	required init?(coder: NSCoder) { fatalError() }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let con = Session.activeConversation {
			layoutableView.activeConversationView.configure(with: con)
            layoutableView.setupStatusIfSessionActive(true)
        } else {
            layoutableView.setupStatusIfSessionActive(Session.activeConversation != nil)
        }
	}
	
	override func bindUIControls() {
		super.bindUIControls()
		layoutableView.chatContainer.startChatButton.action = viewModel.triggerChatScreen
		layoutableView.activeConversationView.startChatButton.action = viewModel.triggerChatScreen
        layoutableView.welcomeContainer.closeButton.action = viewModel.closeChat
        layoutableView.activeConversationtanTaphandler = viewModel.triggerChatScreen
        
        NotificationCenter.default.addObserver(forName: Notification.SessionTerminationNotification.name, object: nil, queue: .main) { [weak self] _ in
            Flow.delay(for: 1) {
                self?.layoutableView.setupStatusIfSessionActive(false)
            }
        }
	}
	
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
	override func bindViewModel() {
		viewModel.statusHandler = { [weak self] newStstus in
			self?.render(state: newStstus)
		}
        
        viewModel.refreshRecentMessages = { newMessage in
            self.layoutableView.activeConversationView.configure(with: newMessage)
        }
        viewModel.fetchOnlineAgents()
        viewModel.listenForAgentStatus()
        
        viewModel.redirectHandler = { [weak self] in
            guard let self = self else { return }
            self.layoutableView.activeConversationView.startChatButton.isUserInteractionEnabled = true
            self.layoutableView.chatContainer.startChatButton.isUserInteractionEnabled = true
        }
	}
}

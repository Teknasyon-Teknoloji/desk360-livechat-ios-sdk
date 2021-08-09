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
	}
}

// extension MainViewController: UITableViewDelegate, UITableViewDataSource {
//
//	func numberOfSections(in tableView: UITableView) -> Int {
//		return sections.count
//	}
//
//	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		let section = sections[section]
//		if section.isExpanded {
//			return 2
//		} else {
//			return 1
//		}
//	}
//
//	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		if indexPath.row == 0 {
//			let cell = tableView.dequeueReusableCell(for: indexPath, cellType: FaqBaseCell.self)
//			cell.faqTitleLable.text = sections[indexPath.section].faq.title
//			cell.isExpanded = sections[indexPath.section].isExpanded
//			cell.isLastCell = indexPath.section == sections.count - 1
//			return cell
//		} else {
//			let cell = tableView.dequeueReusableCell(for: indexPath, cellType: FaqDetailTableViewCell.self)
//			cell.faqDetailsLable.text = sections[indexPath.section].faq.description
//			return cell
//		}
//	}
//
//	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		tableView.deselectRow(at: indexPath, animated: true)
//		let section = sections[indexPath.section]
//		if indexPath.row == 0 {
//			section.isExpanded = !section.isExpanded
//			tableView.reloadSections([indexPath.section], with: .automatic)
//			tableView.reloadRows(at: [indexPath], with: .automatic)
//		} else {
//			let viewModel = FaqDetailsViewModel(faq: section.faq)
//			let faqDetailsVC = FaqDetailsViewController(viewModel: viewModel)
//			self.navigationController?.pushViewController(faqDetailsVC, animated: true)
//		}
//	}
// }
//
// extension MainViewController: UISearchBarDelegate {
//	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//		let viewModel = FaqSearchViewModel()
//		let viewController = FaqSearchViewController(viewModel: viewModel)
//		self.navigationController?.pushViewController(viewController, animated: true)
//	}
// }

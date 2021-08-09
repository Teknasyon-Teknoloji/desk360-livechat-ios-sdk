//
//  FaqSearchViewController.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 21.04.2021.
//

import UIKit

class FaqSearchViewModel {
	
}

final class FaqSearchViewController: UIViewController, Layouting, ViewModelIntializing {
	typealias ViewType  = FaqSearchView
	typealias ViewModel = FaqSearchViewModel
	
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

	override func viewDidLoad() {
		super.viewDidLoad()
		UIApplication.shared.statusBarUIView?.backgroundColor = config?.general.backgroundHeaderColor.uiColor
		view.backgroundColor = .white
//		layoutableView.tableView.delegate = self
//		layoutableView.tableView.dataSource = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		layoutableView.searchBar.becomeFirstResponder()
	}
}
//
// extension FaqSearchViewController: UITableViewDelegate, UITableViewDataSource {
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
//			let cell = tableView.dequeueReusableCell(for: indexPath, cellType: FaqSearchCell.self)
//			cell.faqTitleLable.text = sections[indexPath.section].faq.title
//			cell.isExpanded = sections[indexPath.section].isExpanded
//			cell.isLastCell = indexPath.section == sections.count - 1
//			return cell
//		} else {
//			let cell = tableView.dequeueReusableCell(for: indexPath, cellType: FaqDetailTableViewCell.self)
//			cell.insetContent(by: .init(v: 0, h: 25))
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
//
//	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//		UIView(backgroundColor: .white)
//	}
//
//	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//		return 10
//	}
// }

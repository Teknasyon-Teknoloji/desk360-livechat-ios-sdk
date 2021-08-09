//
//  FaqDetailsViewController.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 19.04.2021.
//

import UIKit

class FaqDetailsViewModel {
	let faq: Faq
	
	init(faq: Faq) {
		self.faq = faq
	}
}

final class FaqDetailsViewController: UIViewController, ViewModelIntializing, Layouting {
	
	typealias ViewType = FaqDetailsView
	typealias ViewModel = FaqDetailsViewModel
	
	var viewModel: FaqDetailsViewModel
	
	override func loadView() {
		view = ViewType.create()
	}
	
	init(viewModel: FaqDetailsViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	@available(*, unavailable, message: "init(coder:) has not been implemented")
	required init?(coder: NSCoder) { fatalError() }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		layoutableView.tableView.delegate = self
		layoutableView.tableView.dataSource = self
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.layoutableView.tableView.reloadData()
	}
}

// MARK: - TableView Methods
extension FaqDetailsViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(for: indexPath, cellType: FaqDetailsCell.self)
		cell.faqTitleLabel.text = viewModel.faq.title
		cell.faqDetailsLabel.text = viewModel.faq.description
		return cell
	}
}

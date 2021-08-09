//
//  FaqSearchView.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 21.04.2021.
//

import UIKit

final class FaqSearchView: UIView, Layoutable {
	
	lazy var welcomeContainer: MainView.TopContainer = {
		MainView.TopContainer.create()
	}()
	
	lazy var currentAgentView: ActiveConversationView = {
		let agentView = ActiveConversationView.create()
		return agentView
	}()
	
	lazy var titleLable: UILabel = {
		let label = UILabel()
		label.font = FontFamily.Gotham.medium.font(size: 16)
		label.textColor = .martinique
		label.text = "Search through our FAQ"
		label.textAlignment = .center
		return label
	}()
	
	lazy var searchBar: UISearchBar = {
		let searchBar = UISearchBar()
		searchBar.placeholder = Strings.faqSearchPlaceholder
		searchBar.backgroundColor = .clear
		searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
		searchBar.searchField?.textColor = .martinique
		searchBar.searchField?.layer.cornerRadius = 18
		searchBar.searchField?.backgroundColor = UIColor(hex: "#f3f5f8")
		searchBar.searchField?.clipsToBounds = true
		searchBar.setSize(.init(width: bounds.width, height: 44))
		return searchBar
	}()
	
	lazy var tableView: UITableView = {
		let table = UITableView()
		table.register(cellType: FaqSearchCell.self)
		table.register(cellType: FaqDetailTableViewCell.self)
		table.tableFooterView = footer
		table.separatorStyle = .none
		table.estimatedRowHeight = 70
		table.keyboardDismissMode = .onDrag
		return table
	}()
		
	lazy var footer: FaqSearchFooter = {
		let footer = FaqSearchFooter.create()
		footer.frame = .init(x: 0, y: 0, width: frame.width, height: 100)
		return footer
	}()
	
	private lazy var desk360LogoView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = Images.desk360
		return imageView
	}()
	
	lazy var searchStack: UIView = .vStack(
		alignment: .center,
		distribution: .fill,
		spacing: 10,
		margins: .init(v: 10, h: 10),
		[titleLable, searchBar]
	)
	
	func setupViews() {}
	
	func setupLayout() {}
	
	override func layoutSubviews() {
		super.layoutSubviews()
	
		addSubview(welcomeContainer)
		addSubview(currentAgentView)
		addSubview(searchStack)
		addSubview(tableView)
		addSubview(desk360LogoView)
		
		desk360LogoView.centerXToSuperview()
		desk360LogoView.anchor(
			bottom: bottomAnchor,
			padding: .init(top: 0, left: 0, bottom: 30, right: 0))
		
		welcomeContainer.setSize(.init(width: frame.width, height: 250))
		welcomeContainer.anchor(
		   top: topAnchor,
		   leading: leadingAnchor,
		   bottom: nil,
		   trailing: trailingAnchor
		)
		
		currentAgentView.anchor(
			top: welcomeContainer.bottomAnchor,
			leading: leadingAnchor,
			bottom: nil,
			trailing: trailingAnchor
		)
		
		searchStack.anchor(
			top: currentAgentView.bottomAnchor,
			leading: leadingAnchor,
			bottom: nil,
			trailing: trailingAnchor,
			size: .init(width: 0, height: 120)
		)
		
		tableView.anchor(
			top: searchStack.bottomAnchor,
			leading: leadingAnchor,
			bottom: desk360LogoView.topAnchor,
			trailing: trailingAnchor,
			padding: .init(v: 10, h: 0)
		)
		
		currentAgentView.addBorders(
			edges: .bottom,
			color: UIColor.santasGray.withAlphaComponent(0.3),
			inset: 20
		)
	}
}

class FaqSearchCell: FaqBaseCell {
	
	override var titleColor: UIColor {
		.black
	}
	
	override func layoutSubviews() {
		stackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
		stackView.fillSuperview(padding: .init(v: 0, h: 20))
		stackView.addBorders(edges: .all, color: UIColor.santasGray.withAlphaComponent(0.1))
	}
}

class FaqSearchFooter: UIView, Layoutable {
	
	lazy var backButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Back", for: .normal)
		button.backgroundColor = .blueRibbon
		button.layer.cornerRadius = 22
		return button
	}()
	
	lazy var loadMoreButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Back", for: .normal)
		button.backgroundColor = .blueRibbon
		button.layer.cornerRadius = 22
		return button
	}()
	
	lazy var stack: UIView = .vStack(
		alignment: .center,
		distribution: .fill,
		spacing: 15,
		margins: .init(v: 20, h: 20),
		[loadMoreButton, backButton]
	)
	
	func setupViews() {
		addSubview(stack)
	}
	
	func setupLayout() {
		stack.centerXToSuperview()
		stack.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		loadMoreButton.setSize(.init(width: frame.width * 0.65, height: 44))
		backButton.setSize(.init(width: frame.width * 0.65, height: 44))
	}
}

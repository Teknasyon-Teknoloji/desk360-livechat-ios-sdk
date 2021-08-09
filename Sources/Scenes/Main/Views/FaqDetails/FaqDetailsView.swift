//
//  FaqDetailsView.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 19.04.2021.
//

import UIKit

class FaqDetailsView: UIView, Layoutable {
	
	lazy var welcomeContainer: MainView.TopContainer = {
		MainView.TopContainer.create()
	}()
	
	lazy var currentAgentView: ActiveConversationView = {
		let agentView = ActiveConversationView.create()
		return agentView
	}()
	
	lazy var tableView: UITableView = {
		let table = UITableView()
		table.register(cellType: FaqDetailsCell.self)
		table.tableFooterView = footer
		table.separatorStyle = .none
		return table
	}()
		
	lazy var footer: FaqDetailsFooter = {
		let footer = FaqDetailsFooter.create()
		footer.frame = .init(x: 0, y: 0, width: frame.width, height: 55)
		return footer
	}()
	
	private lazy var desk360LogoView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = Images.desk360
		return imageView
	}()
	
	func setupViews() {
		backgroundColor = .white
		addSubview(welcomeContainer)
		addSubview(currentAgentView)
		addSubview(tableView)
		addSubview(desk360LogoView)
	}
	
	func setupLayout() {
		desk360LogoView.centerXToSuperview()
		desk360LogoView.anchor(
			bottom: bottomAnchor,
			padding: .init(top: 0, left: 0, bottom: 30, right: 0))
		
		welcomeContainer.anchor(
			top: topAnchor,
			leading: leadingAnchor,
			bottom: nil,
			trailing: trailingAnchor,
			size: .init(width: 0, height: 250)
		)
		
		currentAgentView.anchor(
			top: welcomeContainer.bottomAnchor,
			leading: leadingAnchor,
			bottom: nil,
			trailing: trailingAnchor
		)
		
		tableView.anchor(
			top: currentAgentView.bottomAnchor,
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

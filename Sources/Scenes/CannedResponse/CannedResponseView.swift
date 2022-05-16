//
//  CannedResponseView.swift
//  Desk360LiveChat
//
//  Created by Alper Tabak on 23.02.2022.
//

import Foundation
import UIKit

final class CannedResponseView: UIView, Layoutable, Loadingable {
	lazy var agentView: ChatAgentView = {
		let view = ChatAgentView.create()
		view.optionsButton.isHidden = true
		return view
	}()
	
	lazy var collectionView: MessagesCollectionView = {
		let layout = MessagesCollectionViewFlowLayout()
		layout.minimumLineSpacing = 12
		let collectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.alwaysBounceVertical = true
		if #available(iOS 13.0, *) {
			collectionView.automaticallyAdjustsScrollIndicatorInsets = false
		}
		collectionView.backgroundColor = config?.general.backgroundMainColor.uiColor
		collectionView.register(ChatTextMessageCell.self)
		collectionView.register(CannedResponseButtonCell.self)
		collectionView.register(CannedResponseCloseCell.self)
		collectionView.register(CannedResponseTextCell.self)
		collectionView.register(CannedResponseSurveyCell.self)
		collectionView.register(ChatMessageCellFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
		collectionView.remembersLastFocusedIndexPath = true
		//        collectionView.contentInset = .init(top: 150, left: 0, bottom: 0, right: 0)
		collectionView.backgroundColor = .clear
		collectionView.delaysContentTouches = false
		return collectionView
	}()
		
	var endChatAction: (() -> Void)?
	var sendTranscriptAction: (() -> Void)?
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		endEditing(true)
	}
	
	lazy var recentMessagesBadge: ActionButton = {
		let view = ActionButton(type: .system)
		view.setSize(.init(width: 44, height: 44))
		view.backgroundColor = config?.chat.messageBackgroundColor.uiColor?.darker()
		view.setImage(Images.scrollDown, for: .normal)
		view.layer.cornerRadius = 22
		return view
	}()
	
	lazy var connectivityLabel: PaddingLabel = {
		let label = PaddingLabel()
		label.backgroundColor = UIColor(hex: "#d14059")
		label.text = Strings.sdk_no_connection
		label.translatesAutoresizingMaskIntoConstraints = false
		label.heightAnchor.constraint(equalToConstant: 26).isActive = true
		label.textAlignment = .center
		label.font = FontFamily.Gotham.book.font(size: 11)
		label.layer.cornerRadius = 5
		label.clipsToBounds = true
		label.textColor = .white
		label.insets = .init(top: 0, left: 8, bottom: 0, right: 8)
		return label
	}()
	
	func setupViews() {
		addSubview(agentView)
		addSubview(collectionView)
	}
	
	func showBadgeView(withValue value: Int) {
		recentMessagesBadge.setBadge(in: .northEast, with: "\(value)")
		recentMessagesBadge.isHidden = false
		recentMessagesBadge.transform = .init(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
			self.recentMessagesBadge.transform = .identity
		}
	}
	
	func hideBadgeView(animated: Bool = true) {
		if animated {
			recentMessagesBadge.transform = .init(scaleX: 1, y: 1)
		}
		UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
			self.recentMessagesBadge.transform = .init(scaleX: 0, y: 0)
		} completion: { _ in
			self.recentMessagesBadge.isHidden = true
		}
	}
	
	func updateBadgeView(withValue value: Int) {
		recentMessagesBadge.isHidden = false
		recentMessagesBadge.setBadge(in: .northEast, with: "\(value)")
	}
	
	func setupLayout() {
		agentView.anchor(
			top: safeAreaLayoutGuide.topAnchor,
			leading: leadingAnchor,
			bottom: nil,
			trailing: trailingAnchor
		)
		
		collectionView.anchor(
			top: agentView.bottomAnchor,
			leading: leadingAnchor,
			bottom: safeAreaLayoutGuide.bottomAnchor,
			trailing: trailingAnchor,
			padding: .init(top: 0, left: 0, bottom: 20, right: 0)
		)
	}

}

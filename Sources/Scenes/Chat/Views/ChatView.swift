//
//  ChatListView.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 27.04.2021.
//

import UIKit

final class ChatView: UIView, Layoutable, Loadingable {
    lazy var agentView: ChatAgentView = {
        ChatAgentView.create()
    }()
    
    lazy var collectionView: MessagesCollectionView = {
        let collectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: MessagesCollectionViewFlowLayout())
        collectionView.keyboardDismissMode = .interactive
        collectionView.alwaysBounceVertical = true
        if #available(iOS 13.0, *) {
            collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        }
        collectionView.backgroundColor = config?.general.backgroundMainColor.uiColor
        collectionView.register(ChatTextMessageCell.self)
        collectionView.register(ChatVideoMessageCell.self)
        collectionView.register(ChatErrorVideoCell.self)
        collectionView.register(ChatImageMessageCell.self)
        collectionView.register(ChatDocumentMessageCell.self)
        collectionView.register(ChatMessageCellFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
        //        collectionView.contentInset = .init(top: 150, left: 0, bottom: 0, right: 0)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    lazy var showRecentMessages: ShowNewMessagesView = {
        let view = ShowNewMessagesView()
        return view
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
        addSubview(recentMessagesBadge)
        
        let endChat = ContextMenuAction(
            title: Strings.header_menu_endchat,
            action: { _ in
                self.endChatAction?()
            }
        )
    
        let actions = [endChat]
        let contextMenu = ContextMenu(title: "Please choose an option", actions: actions)
        agentView.optionsButton.addContextMenu(contextMenu, for: .tap(numberOfTaps: 1), .longPress(duration: 0.0))
        
        addSubview(connectivityLabel)
        
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
        
        recentMessagesBadge.anchor(
            top: nil,
            leading: nil,
            bottom: bottomAnchor,
            trailing: trailingAnchor,
            padding: .init(top: 0, left: 0, bottom: 120, right: 20)
        )
        
        bringSubviewToFront(recentMessagesBadge)
        
        connectivityLabel.anchor(
            top: nil,
            leading: leadingAnchor,
            bottom: bottomAnchor,
            trailing: nil,
            padding: .init(top: 0, left: 20, bottom: 120, right: 0)
        )
        connectivityLabel.sizeToFit()
        connectivityLabel.layoutIfNeeded()
        
        bringSubviewToFront(connectivityLabel)
    }

}

class PaddingLabel: UILabel {
    var insets: UIEdgeInsets = .zero
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }

    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width - (insets.left + insets.right)
        }
    }
}

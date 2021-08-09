//
//  ShowNewMessagesView.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 1.07.2021.
//

import UIKit

final class ShowNewMessagesView: UIView {
    
    lazy var button: ActionButton = {
        let button = ActionButton(type: .system)
        button.setImage(Images.showRecentMessages, for: .normal)
        return button
    }()
    
    lazy var badge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#f23f3f")
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(button)
        addSubview(badge)
        
        button.setSize(.init(width: 34, height: 34))
        button.centerInSuperview()
        badge.setSize(.init(width: 16, height: 16))
        badge.anchor(
            top: nil,
            leading: nil,
            bottom: button.topAnchor,
            trailing: button.trailingAnchor,
            padding: .init(top: -8, left: -8, bottom: -8, right: -8)
        )
    }
}

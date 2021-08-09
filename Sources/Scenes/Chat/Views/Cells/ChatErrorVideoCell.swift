//
//  ChatErrorVideoCell.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 16.05.2021.
//

import UIKit

final class ChatErrorVideoCell: ChatVideoMessageCell {
	
	override func layoutViews() {
		errorView.isHidden = false
		fileFormatIcon.setSize(.init(width: 20, height: 24))
		fileStack.centerInSuperview()
	}
}

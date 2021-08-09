//
//  ChatMessageCellFooter.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 11.06.2021.
//

import UIKit

final class ChatMessageCellFooter: UICollectionReusableView, Reusable {
	
	lazy var dateLabel: UILabel = {
		let label = UILabel()
		label.textColor = .black
		label.font = FontFamily.Gotham.book.font(size: 10)
		return label
	}()
	
	override func layoutSubviews() {
		super.layoutSubviews()
		addSubview(dateLabel)
		dateLabel.fillSuperview(padding: .init(v: 0, h: 20))
	}
}

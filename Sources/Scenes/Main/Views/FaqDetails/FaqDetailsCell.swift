//
//  FaqDetailsCell.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 20.04.2021.
//

import UIKit

final class FaqDetailsCell: UITableViewCell {
	
	lazy var faqTitleLabel: UILabel = {
		let label = UILabel()
		label.textColor = .black
		label.font = FontFamily.Gotham.medium.font(size: 14)
		return label
	}()
	
	lazy var faqDetailsLabel: UILabel = {
		let label = UILabel()
		label.font = FontFamily.Gotham.book.font(size: 14)
		label.textColor = .martinique
		label.numberOfLines = 0
		return label
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(faqTitleLabel)
		contentView.addSubview(faqDetailsLabel)
		selectionStyle = .none
	}
	
	@available(*, unavailable, message: "init(coder:) has not been implemented")
	required init?(coder: NSCoder) { fatalError() }
	
	override func layoutSubviews() {
		super.layoutSubviews()
		faqTitleLabel.anchor(
			top: contentView.topAnchor,
			leading: contentView.leadingAnchor,
			bottom: nil,
			trailing: contentView.trailingAnchor,
			padding: .init(top: 10, left: 20, bottom: 0, right: 20)
		)
		
		faqDetailsLabel.anchor(
			top: faqTitleLabel.bottomAnchor,
			leading: contentView.leadingAnchor,
			bottom: contentView.bottomAnchor,
			trailing: contentView.trailingAnchor,
			padding: .init(v: 20, h: 20)
		)
	}
}

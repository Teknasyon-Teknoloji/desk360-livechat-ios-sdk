//
//  FaqTableViewCell.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 16.04.2021.
//

import UIKit

class FaqBaseCell: UITableViewCell {
	lazy var ribbonImage: UIImageView = {
		let imageView = UIImageView()
		imageView.image = Images.ribbon
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	lazy var faqTitleLable: UILabel = {
		let label = UILabel()
		label.textColor = .santasGray
		label.font = FontFamily.Gotham.book.font(size: 14)
		return label
	}()
	
	lazy var stackView: UIView = .hStack(
		alignment: .fill,
		distribution: .fill,
		spacing: 10,
		margins: .all(10),
		[
			faqTitleLable,
			.spacer(),
			ribbonImage
		])
	
	open var titleColor: UIColor { .santasGray }
	
	var isExpanded: Bool = false {
		didSet {
			cellDidAppear(isExpanded: isExpanded)
		}
	}
	
	var isLastCell = false
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(stackView)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		stackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
		stackView.fillSuperview()
	}
	
	private func cellDidAppear(isExpanded: Bool) {
		if isExpanded {
			faqTitleLable.textColor = .dodgerBlue
			faqTitleLable.font = FontFamily.Gotham.medium.font(size: 14)
			ribbonImage.tintColor = .dodgerBlue
			let edges: UIRectEdge =  [.top, .left, .right]
			stackView.addBorders(edges: edges, color: UIColor.santasGray.withAlphaComponent(0.1))
		} else {
			faqTitleLable.textColor = titleColor
			faqTitleLable.font = FontFamily.Gotham.book.font(size: 14)
			ribbonImage.tintColor = .santasGray
			let edges: UIRectEdge = isLastCell ? [.all] : [.top, .left, .right]
			stackView.addBorders(edges: edges, color: UIColor.santasGray.withAlphaComponent(0.1))
		}
	}
}

class FaqDetailTableViewCell: UITableViewCell {
	
	lazy var faqDetailsLable: UILabel = {
		let lable = UILabel()
		lable.textColor = .santasGray
		lable.font = FontFamily.Gotham.book.font(size: 14)
		lable.numberOfLines = 0
		return lable
	}()
	
	func insetContent(by inset: UIEdgeInsets) {
		faqDetailsLable.removeFromSuperview()
		contentView.addSubview(faqDetailsLable)
		faqDetailsLable.fillSuperview(padding: inset)
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(faqDetailsLable)
		faqDetailsLable.fillSuperview(padding: .all(8))
		addBorders(
			edges: [.left, .right, .bottom],
			color: UIColor.santasGray.withAlphaComponent(0.1)
		)
	}
	
	@available(*, unavailable, message: "init(coder:) has not been implemented")
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

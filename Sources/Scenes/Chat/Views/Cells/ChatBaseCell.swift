//
//  ChatBaseCell.swift
//  Example
//
//  Created by Ali Ammar Hilal on 12.05.2021.
//

import UIKit

class ChatBaseCell: UICollectionViewCell {

	weak var delegate: MessageCellDelegate?
	
	lazy var bubbleView: BubbleView = {
		let view = BubbleView()
		return view
	}()
	
	lazy var errorView: CellErrorView = {
		let view = CellErrorView()
		view.isHidden = true
		return view
	}()
	
	lazy var dateLabel: UILabel = {
		let label = UILabel()
		label.textColor = .black
        label.font = FontFamily.Gotham.medium.font(size: 10)
		return label
	}()
	
	lazy var tickView: UIImageView = {
		let view = UIImageView()
		view.contentMode = .scaleAspectFill
        view.setSize(.init(width: 16, height: 10))
		return view
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}
	
    lazy var messageLabel: MessageLabel = {
        let label = MessageLabel()
        label.font = FontFamily.Gotham.book.font(size: 15)
        return label
    }()
    
    lazy var tickAndTimeStack: UIView = .hStack(spacing: 4, [dateLabel, tickView])
    
	init() {
		super.init(frame: .zero)
		setupViews()
	}
	
	@available(*, unavailable, message: "init(coder:) has not been implemented")
	required init?(coder: NSCoder) { fatalError() }
	
	func setupViews() {
		contentView.addSubview(bubbleView)
		contentView.addSubview(errorView)
		// contentView.addSubview(dateLabel)
		bubbleView.addSubview(tickAndTimeStack)
	}
	
	func layoutViews() {}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		layoutViews()
	}
	
	var viewModel: MessageCellViewModel? {
		didSet {
			errorView.isHidden = viewModel?.isSentSuccessfully ?? false
            
            if viewModel?.isFromCurrentUser ?? true {
                setuptextColors(config?.general.headerTitleColor.uiColor)
            } else {
                setuptextColors(config?.chat.messageTextColor.uiColor)
            }
		}
	}
	
	func configure(with viewModel: MessageCellViewModel) {
		self.viewModel = viewModel
		bubbleView.backgroundColor = .cadetBlue // config?.chat.messageBackgroundColor.uiColor
		errorView.isHidden = viewModel.isSentSuccessfully
//		let alinmet: NSTextAlignment = viewModel.isFromCurrentUser ? .right : .left
//		dateLabel.textAlignment = alinmet
		dateLabel.text = MessageDateFormatter.shared.onlyHourString(from: viewModel.message.createdAt)// string(from: viewModel.message.createdAt)
		tickView.image = viewModel.state.image
		tickView.isHidden = !viewModel.isFromCurrentUser
        
        if viewModel.isFromCurrentUser {
            bubbleView.backgroundColor = config?.general.backgroundHeaderColor.uiColor
            let color = config?.general.headerTitleColor.uiColor
            let attr: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.underlineColor: color,
                .font: FontFamily.Gotham.book.font(size: 15)
            ]
            
            messageLabel.setAttributes(attr, detector: .url)
            messageLabel.textColor = color

        } else {
            bubbleView.backgroundColor = config?.chat.messageBackgroundColor.uiColor
            let color = config?.chat.messageTextColor.uiColor
            let attr: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.underlineColor: color,
                .font: FontFamily.Gotham.book.font(size: 15)
            ]

            messageLabel.setAttributes(attr, detector: .url)
            messageLabel.textColor = color
        }
        
        messageLabel.enabledDetectors = Array(viewModel.messageDetectors)
        messageLabel.setNeedsDisplay()
	}
	
	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
		super.apply(layoutAttributes)
		guard let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes else { return }
		var x: CGFloat = 0
		let height = attributes.messageContainerSize.height
        var cornerRadius: CGFloat = 0
        if height <= 50 {
            cornerRadius = height * 0.5
        } else if height > 50 && height <= 120 {
            cornerRadius = height * 0.3
        } else {
            cornerRadius = height * 0.1
        }
        
        if height > 500 {
           cornerRadius = 10
        }
		if attributes.isIncomingMessage {
			bubbleView.direction = .left(edgesRaduis: .init(topLeft: 0, topRight: cornerRadius, bottomLeft: cornerRadius, bottomRight: cornerRadius))
		} else {
			x =  attributes.frame.width - attributes.messageContainerSize.width - attributes.messageContainerPadding.right
			bubbleView.direction = .right(edgesRaduis: .init(topLeft: cornerRadius, topRight: 0, bottomLeft: cornerRadius, bottomRight: cornerRadius))
		}
		
		bubbleView.frame = CGRect(origin: .init(x: x, y: 0), size: attributes.messageContainerSize)
		
        let textWidth = CGSize.labelSize(for: Strings.sdk_failed_to_send_message, font: UIFont.systemFont(ofSize: 10), considering: contentView.frame.width).width
		let iconWidth: CGFloat = 30
		let totalWidth = textWidth + iconWidth
		var errorViewX =  bubbleView.frame.minX
		let y = bubbleView.frame.maxY + 8
		if attributes.isIncomingMessage {
			errorViewX = bubbleView.frame.maxX - totalWidth
		}
		errorView.stack.alignment = attributes.cellBottomViewAlignment.alignment.stackViewAlignment()
		errorView.stack.spacing = 4
		errorView.frame.origin = .init(x: errorViewX, y: y)
		errorView.errorLabel.textAlignment = attributes.cellBottomViewAlignment.alignment.textAlignment()
		
		errorView.frame.size = .init(width: textWidth + 30, height: 15)
		if errorView.isHidden {
		//	dateLabel.anchor(top: bubbleView.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(v: 8, h: 10))
		} else {
        //  dateLabel.anchor(top: errorView.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(v: 8, h: 10))
		}
	}
	
    func setuptextColors(_ color: UIColor?) {
        dateLabel.textColor = color
    }
    
	/// Handle tap gesture on contentView and its subviews.
    func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let location = gesture.location(in: messageLabel)
        messageLabel.handleGesture(location)
	}
}

extension Message.Status {
	var image: UIImage? {
		switch self {
		case .read:
			return Images.readTick
        case .sent, .delivered:
			return Images.deliveredTick
		default:
			return nil
		}
	}
}

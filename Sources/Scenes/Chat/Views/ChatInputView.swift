//
//  ChatInputView.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 28.04.2021.
//

import UIKit

class ChatInputView: UIView, Layoutable {
    
    lazy var textView: GrowingTextView = {
        let view = GrowingTextView()
        view.minHeight = 35
        view.maxHeight = 50
        let textColor = config?.chat.writeMessageTextColor.uiColor
        view.attributedPlaceholder = NSAttributedString(string: Strings.online_message, attributes: [.font: FontFamily.Gotham.book.font(size: 14), .foregroundColor: textColor?.withAlphaComponent(0.5)])
        view.backgroundColor = config?.general.backgroundMainColor.uiColor
        view.font = FontFamily.Gotham.book.font(size: 14)
        view.textColor = textColor
        return view
    }()
    
    lazy var sendButton: ActionButton = {
        let button = ActionButton(type: .system)
        button.setSize(.init(width: 44, height: 44))
        button.layer.cornerRadius = 12
        let image = Images.sendChat.tinted(with: config?.chat.writeMessageIconColor.uiColor)
        button.setImage(image, for: .normal)
        button.adjustsImageWhenDisabled = true
        return button
    }()
    
    lazy var emojiButton: ActionButton = {
        let button = ActionButton(type: .system)
        button.setImage(Images.emoji, for: .normal)
        button.setSize(.init(width: 20, height: 20))
        button.isHidden = true
        return button
    }()
    
    lazy var attachmentButton: ActionButton = {
        let button = ActionButton(type: .system)
        let image = Images.attacment.tinted(with: config?.chat.writeMessageIconColor.uiColor)
        button.setImage(image, for: .normal)
        button.setSize(.init(width: 33, height: 33))
        button.isHidden = !(config?.chat.addFileStatus ?? true)
        return button
    }()
    
    lazy var desk360Logo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Images.desk360
        return imageView
    }()
    
    private lazy var hStack: UIView = .hStack(
        alignment: .center,
        distribution: .fill,
        spacing: 15,
        margins: nil,
        [
            attachmentButton,
            textView,
            emojiButton,
            sendButton
        ]
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
        backgroundColor = config?.general.backgroundMainColor.uiColor
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setupViews() {
        addSubview(hStack)
        addSubview(desk360Logo)
        attachmentButton.isHidden = !(config?.chat.addFileStatus ?? true)
        
        if let chatbot = Storage.settings.object?.chatbot {
            attachmentButton.isHidden = chatbot
        }
    }
    
    var hidesLogoView: Bool = false {
        didSet {
            self.desk360Logo.isHidden = hidesLogoView
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let height: CGFloat = hidesLogoView ? 60 : 100
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
    
    func setupLayout() {
        
        autoresizingMask = [.flexibleHeight]
        
        desk360Logo.anchor(
            top: nil,
            leading: nil,
            bottom: safeAreaLayoutGuide.bottomAnchor,
            trailing: nil,
            padding: .init(v: 8, h: 0)
        )
        desk360Logo.centerXToSuperview()
        
        hStack.anchor(
            top: topAnchor,
            leading: leadingAnchor,
            bottom: desk360Logo.topAnchor,
            trailing: trailingAnchor,
            padding: .init(v: 8, h: 20)
        )
        
        addBorders(edges: .top, color: UIColor.santasGray.withAlphaComponent(0.3))
    }
}

//
//  ContactInfoView.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 23.04.2021.
//

import UIKit

final class ContactInfoView: UIView, Layoutable, Loadingable {
    
    var customFieldsArray: Array<ValidatableField> = []
    
    var isOnline: Bool = false {
        didSet {
            customFieldsArray.forEach { $0.removeFromSuperview() }
            customFieldsArray = customFields()
            setupLayout()
        }
    }
	
	var credentials: Credentials? {
		didSet {
			guard let credentials = credentials else { return }
			self.nameTextField.text = credentials.name
			self.emailTextField.text = credentials.email
		}
	}
    
    private lazy var desk360LogoView: Desk360View = {
        let imageView = Desk360View()
        return imageView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.keyboardDismissMode = .onDrag
        return view
    }()
    
    lazy var chatAgentView: ChatAgentView = {
        ChatAgentView.create()
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = Strings.welcome_message
        label.numberOfLines = 0
        label.textColor = config?.general.sectionHeaderTitleColor.uiColor
        return label
    }()
    
    lazy var nameTextField: ValidatableField = {
        let textField = ValidatableField(padding: .init(top: 0, left: 10, bottom: 0, right: 44))
        let color = config?.chat.placeholderColor.uiColor
        let font = FontFamily.Gotham.book.font(size: 14)
        textField.attributedPlaceholder = .init(string: Strings.login_input_name + "*", attributes: [.font: font, .foregroundColor: color?.withAlphaComponent(0.7)])
        textField.font = FontFamily.Gotham.book.font(size: 14)
        textField.textLimit = 50
        textField.textColor = config?.chat.messageTextColor.uiColor
        textField.showsTextLimit = true
        textField.validators = [.notEmpty]
        return textField
    }()
    
    lazy var emailTextField: ValidatableField = {
        let textField = ValidatableField(padding: .init(top: 0, left: 10, bottom: 0, right: 10))
        let color = config?.chat.placeholderColor.uiColor
        let font = FontFamily.Gotham.book.font(size: 14)
        textField.attributedPlaceholder = .init(string:  Strings.login_input_email + "*", attributes: [.font: font, .foregroundColor: color?.withAlphaComponent(0.7)])
        textField.font = font
        textField.textColor = config?.chat.messageTextColor.uiColor
        textField.validators = [.notEmpty, .email]
        textField.shouldWiatValidation = true
        textField.autoCorrectionEnabled = .no
        return textField
    }()
    
    lazy var messageField: GrowingTextView = {
        let view = GrowingTextView()
        let color = config?.chat.placeholderColor.uiColor
        view.minHeight = 80
        view.maxHeight = 200
        view.font = FontFamily.Gotham.book.font(size: 14)
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 1
        view.keyboardDismissMode = .onDrag
        view.layer.borderColor = color?.cgColor
        let font = FontFamily.Gotham.book.font(size: 14)
        view.textColor = config?.chat.messageTextColor.uiColor
        view.attributedPlaceholder = .init(string: Strings.offline_input_your_message, attributes: [.font: font, .foregroundColor: color?.withAlphaComponent(0.7)])
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var messageErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.text = Strings.required_message
        label.font = FontFamily.Gotham.book.font(size: 11)
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()
    
    lazy var startChatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.startChatSendMessageButtonText, for: .normal)
        button.setTitleColor(config?.general.sendButtonTextColor.uiColor, for: .normal)
        let image = Images.send.tinted(with: config?.general.sendButtonTextColor.uiColor)
        button.setImage(image, for: .normal)
        button.backgroundColor = config?.general.sendButtonBackgroundColor.uiColor
        button.imageEdgeInsets.left = -20
        button.layer.cornerRadius = 22
        button.titleLabel?.font = FontFamily.Gotham.medium.font(size: 14)
        return button
    }()
    
    func setupViews() { }
    
    func setupLayout() {
        var fieldsStack: UIView  = {
            .vStack(
                alignment: .fill,
                distribution: .fill,
                spacing: 0,
                [
                    nameTextField,
                    emailTextField,
                ] + customFieldsArray + [messageField]
            )
        }()
        
        
        var contentView: UIView = {
            let view = UIView()
            view.addSubview(messageLabel)
            view.addSubview(messageErrorLabel)
            view.addSubview(fieldsStack)
            view.addSubview(startChatButton)
            return view
        }()
        
        addSubview(chatAgentView)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        chatAgentView.optionsButton.isHidden = true
        backgroundColor = .white
        addSubview(desk360LogoView)
        
        chatAgentView.anchor(
            top: safeAreaLayoutGuide.topAnchor,
            leading: leadingAnchor,
            bottom: nil,
            trailing: trailingAnchor,
            size: .init(width: 0, height: 60)
        )
        
        scrollView.anchor(
            top: chatAgentView.bottomAnchor,
            leading: leadingAnchor,
            bottom: desk360LogoView.topAnchor,
            trailing: trailingAnchor,
            padding: .init(v: 20, h: 0)
        )
        
        contentView.anchor(
            top: scrollView.topAnchor,
            leading: scrollView.leadingAnchor,
            bottom: scrollView.bottomAnchor,
            trailing: scrollView.trailingAnchor
        )
        
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        messageLabel.anchor(
            top: scrollView.topAnchor,
            leading: leadingAnchor,
            bottom: nil,
            trailing: trailingAnchor,
            padding: .init(v: 70, h: 50)
        )
        
        messageErrorLabel.anchor(
            top: messageField.bottomAnchor,
            leading: leadingAnchor,
            bottom: nil,
            trailing: trailingAnchor,
            padding: .init(v: 8, h: 20)
        )
        
        fieldsStack.anchor(
            top: messageLabel.bottomAnchor,
            leading: leadingAnchor,
            bottom: nil,
            trailing: trailingAnchor,
            padding: .init(v: 20, h: 20)
        )
        
        startChatButton.centerXToSuperview()
        let buttonTopAnchor: NSLayoutYAxisAnchor = isOnline ? fieldsStack.bottomAnchor : messageErrorLabel.bottomAnchor
        startChatButton.anchor(
            top: buttonTopAnchor,
            leading: nil,
            bottom: contentView.bottomAnchor,
            trailing: nil,
            padding: .init(v: 25, h: 20)
        )
        
        desk360LogoView
            .anchor(
                top: nil,
                leading: leadingAnchor,
                bottom: safeAreaLayoutGuide.bottomAnchor,
                trailing: trailingAnchor,
                size: .init(width: frame.width, height: 44)
            )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        startChatButton.setSize(.init(width: frame.width * 0.6, height: 44))
    }
    
    func configure(with agentStaus: ContactInfoViewModel.AgentStatus) {
        switch agentStaus {
        case.online:
            messageField.isHidden = true
            messageErrorLabel.isHidden = true
            isOnline = true
            chatAgentView.typingInfolabel.text = config?.online.headerText
        case .offline:
            messageField.isHidden = false
            isOnline = false
            chatAgentView.typingInfolabel.text = config?.offline.headerText
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if touches.first?.location(in: scrollView) != nil {
            scrollView.endEditing(true)
        }
        endEditing(true)
    }
    
    private func customFields() -> [ValidatableField] {
        guard let fileds = config?.offline.customFields, !isOnline else { return [] }
        return fileds.map { field -> ValidatableField in
            let textField = ValidatableField(padding: .init(top: 0, left: 10, bottom: 0, right: 10))
            textField.placeholder = field.title
            textField.key = field.key ?? ""
            textField.validators = [.notEmpty]
            textField.font = FontFamily.Gotham.book.font(size: 14)
            textField.textColor = config?.chat.messageTextColor.uiColor
            return textField
        }
    }
}

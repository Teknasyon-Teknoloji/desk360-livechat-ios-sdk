//
//  ContactInfoView.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 23.04.2021.
//

import UIKit

final class ContactInfoView: UIView, Layoutable, Loadingable {

    var isOnline: Bool = false {
        didSet {
            setupLayout()
        }
    }

	lazy var chatAgentView: ChatAgentView = {
		ChatAgentView.create()
	}()
	
	lazy var messageLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.text = Strings.welcome_message
		label.numberOfLines = 2
		return label
	}()
	
	lazy var nameTextField: CustomTextField = {
        let textField = CustomTextField(padding: .init(top: 0, left: 10, bottom: 0, right: 44))
		textField.placeholder =  Strings.login_input_name + "*"
		textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
		textField.layer.cornerRadius = 4
		textField.layer.borderWidth = 1
		textField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        textField.font = FontFamily.Gotham.book.font(size: 14)
        textField.textLimit = 50
		return textField
	}()
	
	lazy var nameErrorLabel: UILabel = {
		let label = UILabel()
		label.textColor = .red
		label.text = Strings.required_message
		label.font = FontFamily.Gotham.book.font(size: 11)
		label.textAlignment = .left
		label.isHidden = true
		return label
	}()
	
	lazy var emailTextField: CustomTextField = {
		let textField = CustomTextField()
		textField.placeholder = Strings.login_input_email + "*"
		textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
		textField.layer.cornerRadius = 4
		textField.layer.borderWidth = 1
		textField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        textField.font = FontFamily.Gotham.book.font(size: 14)
		return textField
	}()
	
    lazy var nameFieldLimit: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .lightGray
        label.text = "50/50"
        return label
    }()
    
	lazy var emailErrorLabel: UILabel = {
		let label = UILabel()
		label.textColor = .red
		label.text =  Strings.required_message
		label.font = FontFamily.Gotham.book.font(size: 11)
		label.textAlignment = .left
		label.isHidden = true
		return label
	}()
	    
	lazy var messageField: GrowingTextView = {
		let view = GrowingTextView()
		view.placeholder = Strings.offline_input_your_message
		view.minHeight = 80
		view.maxHeight = 200
        view.font = FontFamily.Gotham.book.font(size: 14)
		view.layer.cornerRadius = 4
		view.layer.borderWidth = 1
		view.keyboardDismissMode = .onDrag
		view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        let font = FontFamily.Gotham.book.font(size: 14)
        let color = UIColor.lightGray
        view.attributedPlaceholder = .init(string: Strings.offline_input_your_message, attributes: [.font: font, .foregroundColor: color])
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
	
	lazy var fieldsStack: UIView = .vStack(
		alignment: .fill,
		distribution: .fill,
		spacing: 8, [
			nameTextField,
			nameErrorLabel,
			emailTextField,
			emailErrorLabel,
			messageField
		]
	)
	
	lazy var startChatButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle(Strings.startChatSendMessageButtonText, for: .normal)
		button.setTitleColor(config?.general.sendButtonTextColor.uiColor, for: .normal)
        
		button.setImage(Images.send.withRenderingMode(.alwaysOriginal), for: .normal)
		// button.imageView?.setTintColor(config?.general.sendButtonIconColor.uiColor)
		button.backgroundColor = config?.general.sendButtonBackgroundColor.uiColor
		button.imageEdgeInsets.left = -20
		button.layer.cornerRadius = 22
		button.titleLabel?.font = FontFamily.Gotham.medium.font(size: 14)
		return button
	}()
	
	func setupViews() {
		addSubview(chatAgentView)
		addSubview(messageLabel)
		addSubview(messageErrorLabel)
		addSubview(fieldsStack)
		addSubview(startChatButton)
		chatAgentView.optionsButton.isHidden = true
        addSubview(nameFieldLimit)
	}
	
	func setupLayout() {
		chatAgentView.anchor(
			top: safeAreaLayoutGuide.topAnchor,
			leading: leadingAnchor,
			bottom: nil,
			trailing: trailingAnchor,
			size: .init(width: 0, height: 60)
		)
		
//		companyStack.anchor(
//			top: chatAgentView.topAnchor,
//			leading: chatAgentView.leadingAnchor,
//			bottom: nil,
//			trailing: chatAgentView.trailingAnchor,
//			padding: .init(v: 10, h: 20)
//		)
		
		messageLabel.anchor(
			top: chatAgentView.bottomAnchor,
			leading: leadingAnchor,
			bottom: nil,
			trailing: trailingAnchor,
			padding: .init(v: 20, h: 50)
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
			bottom: nil,
			trailing: nil,
			padding: .init(v: 25, h: 20)
		)
        
        nameFieldLimit.anchor(
            bottom: nameTextField.bottomAnchor,
            trailing: nameTextField.trailingAnchor,
            padding: .init(top: 0, left: 0, bottom: 8, right: 8)
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
	
    private func onlineUserLayout() {
        
    }
    
    private func offlineUserLayout() {
        
    }
    
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		endEditing(true)
	}
}

class CustomTextField: UITextField, UITextFieldDelegate {

    var textLimit = 0
    private var padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    init(padding: UIEdgeInsets) {
        self.padding = padding
        super.init(frame: .zero)
        delegate = self
    }
    
	override init(frame: CGRect) {
		super.init(frame: frame)
        delegate = self
	}
	
	func setPlaceHolderTextColor(_ color: UIColor) {
		guard let holder = placeholder, !holder.isEmpty else { return }
		attributedPlaceholder = NSAttributedString(string: holder, attributes: [.foregroundColor: color])
	}
	
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	 func shakeTextField() {
		let shake: CABasicAnimation = CABasicAnimation(keyPath: "position")
		shake.duration = 0.1
		shake.repeatCount = 2
		shake.autoreverses = true
		
		let fromPoint: CGPoint = CGPoint(x: self.center.x - 5, y: self.center.y)
		let fromValue: NSValue = NSValue(cgPoint: fromPoint)
		
		let toPoint: CGPoint = CGPoint(x: self.center.x + 5, y: self.center.y)
		let toValue: NSValue = NSValue(cgPoint: toPoint)
		
		shake.fromValue = fromValue
		shake.toValue = toValue
		self.layer.add(shake, forKey: "position")
	}
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textLimit <= 0 { return true }
        
        guard let preText = textField.text as NSString?,
              preText.replacingCharacters(in: range, with: string).count <= textLimit else {
            return false
        }
        
        return true
    }
}

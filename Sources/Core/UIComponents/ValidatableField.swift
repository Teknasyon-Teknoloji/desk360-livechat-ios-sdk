//
//  ValidatableField.swift
//  Desk360LiveChat
//
//  Created by Ali Ammar Hilal on 14.08.2021.
//

import UIKit

final class ValidatableField: UIView {
    
    var key: String = ""
    
    var shouldWiatValidation = false
    
    var showsTextLimit = false {
        didSet {
            fieldTextLimit.isHidden = !showsTextLimit
        }
    }
    
    var isValid = false {
        didSet {
            errorLabel.isHidden = isValid
        }
    }
    
    var errorMessage: String? = nil {
        didSet {
            isValid = errorMessage == nil
            errorLabel.text = errorMessage
            invalidateIntrinsicContentSize()
        }
    }
    
    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }
    
    var attributedPlaceholder: NSAttributedString? {
        get { textField.attributedPlaceholder }
        set { textField.attributedPlaceholder = newValue }
    }
    
    var font: UIFont? {
        get {  textField.font }
        set { textField.font = newValue }
    }
    
    var textColor: UIColor? {
        get { textField.textColor }
        set { textField.textColor = newValue }
    }
    
    var placeholder: String? {
        get { textField.placeholder }
        set { textField.placeholder = newValue }
    }
    
    var textLimit: Int {
        get { textField.textLimit }
        set { textField.textLimit = newValue }
    }
    
    var autoCorrectionEnabled: UITextAutocorrectionType = .default {
        didSet {
            textField.autocorrectionType = autoCorrectionEnabled
        }
    }
    
    typealias ValidationRule = Validator<String, String>.Rule<String, String>
    var validators: [ValidationRule] = []
    
    private let textPadding: UIEdgeInsets

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.text = Strings.required_message
        label.font = FontFamily.Gotham.book.font(size: 11)
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()
    
    private lazy var textField: CustomTextField = {
        let textField = CustomTextField(padding: textPadding)
        let color = config?.chat.placeholderColor.uiColor
        let font = FontFamily.Gotham.book.font(size: 14)
        textField.attributedPlaceholder = .init(string: Strings.login_input_name + "*", attributes: [.font: font, .foregroundColor: color?.withAlphaComponent(0.7)])
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.layer.cornerRadius = 4
        textField.layer.borderWidth = 1
        textField.layer.borderColor = color?.cgColor
        textField.font = FontFamily.Gotham.book.font(size: 14)
        textField.textLimit = 50
        textField.textColor = config?.chat.messageTextColor.uiColor
        textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        textField.autocorrectionType = .no
        return textField
    }()
    
    private lazy var fieldTextLimit: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.text = "0/50"
        label.textColor = config?.chat.placeholderColor.uiColor
        label.isHidden = true
        return label
    }()
    
    init(padding: UIEdgeInsets) {
        self.textPadding = padding
        super.init(frame: .zero)
        Flow.delay(for: 0.1) {
            self.errorMessage = nil
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override var intrinsicContentSize: CGSize {
        let labelHeight = isValid ? 0 : errorLabel.bounds.height
        return .init(width: self.frame.width, height: 44 + labelHeight)
    }
    
    func addTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        textField.addTarget(target, action: action, for: event)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(textField)
        addSubview(errorLabel)
        addSubview(fieldTextLimit)
        
        textField.anchor(
            top: topAnchor,
            leading: leadingAnchor,
            bottom: nil,
            trailing: trailingAnchor
        )
        
        errorLabel.anchor(
            top: textField.bottomAnchor,
            leading: leadingAnchor,
            bottom: bottomAnchor,
            trailing: trailingAnchor,
            padding: .init(v: 4, h: 8)
        )
    
        fieldTextLimit.centerYTo(textField.centerYAnchor)
        fieldTextLimit.anchor(
            bottom: nil,
            trailing: trailingAnchor,
            padding: .init(top: 0, left: 0, bottom: 0, right: 6)
        )
    }
}

extension ValidatableField: UITextFieldDelegate {
    
    @objc private func textDidChange(_ sender: UITextField) {
        if shouldWiatValidation && errorMessage == nil {
            return
        } else if shouldWiatValidation && errorMessage != nil {
            validate()
        } else {
            validate()
        }
    }
    
    private func validate() {
        let text = textField.text ?? ""
        fieldTextLimit.text = "\(text.count)/50"
        let result = validators.compactMap { $0.check(text) }
        errorMessage = result.first
    }
}

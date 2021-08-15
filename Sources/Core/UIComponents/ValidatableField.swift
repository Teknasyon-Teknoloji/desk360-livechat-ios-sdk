//
//  ValidatableField.swift
//  Desk360LiveChat
//
//  Created by Ali Ammar Hilal on 14.08.2021.
//

import UIKit

final class ValidatableField: UIView {
    
    var key: String = ""
    
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
    
    lazy var textField: CustomTextField = {
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
        return textField
    }()
    
    init(padding: UIEdgeInsets) {
        self.textPadding = padding
        super.init(frame: .zero)
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
    }
}

//
//  ContactInfoViewController.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 23.04.2021.
//

import UIKit

final class ContactInfoViewController: BaseViewController, Layouting, ViewModelIntializing {
    
    typealias ViewType = ContactInfoView
    typealias ViewModel = ContactInfoViewModel
    
    let viewModel: ContactInfoViewModel
    
    init(viewModel: ContactInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "init(coder:) has not been implemented")
    required init?(coder: NSCoder) { fatalError() }
    
    override func loadView() {
        view = ViewType.create()
    }
    
    override func bindUIControls() {
        super.bindUIControls()
        layoutableView.messageField.isHidden = viewModel.isOnline
        layoutableView.chatAgentView.configure(with: nil)
        layoutableView.isOnline = viewModel.isOnline
        listenForUIEvents()
        layoutableView.startChatButton.addTarget(self, action: #selector(didTapSubmitButton), for: .touchUpInside)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        viewModel.listenForAgentStatus()
        
        if viewModel.isOnline {
            layoutableView.chatAgentView.typingInfolabel.text = config?.online.headerText
        } else {
            layoutableView.chatAgentView.typingInfolabel.text = config?.offline.headerText
        }
        
        viewModel.agentStatusHandler = { newStatus in
            self.layoutableView.configure(with: newStatus)
        }
    }
    
    override func setupAppearnace() {
        super.setupAppearnace()
        layoutableView.chatAgentView.configure(with: nil)
        layoutableView.backgroundColor = .white
    }
}

// MARK: - View Helpers
private extension ContactInfoViewController {
    func listenForUIEvents() {
        layoutableView.messageField.delegate = self
        layoutableView.chatAgentView.backButton.action = viewModel.back
        if let cred = Storage.credentails.object {
            layoutableView.emailTextField.text = cred.email
            layoutableView.nameTextField.text = cred.name
        }
    }
}

extension ContactInfoViewController: GrowingTextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        layoutableView.messageErrorLabel.isHidden = !textView.text.trim().isEmpty
    }
}

// MARK: - Actions
private extension ContactInfoViewController {
   
    @objc func didTapSubmitButton() {
        if validate() {
            let email = layoutableView.emailTextField.text ?? ""
            let name = layoutableView.nameTextField.text ?? ""
            if viewModel.isOnline {
                self.render(state: .loading)
                
                viewModel.login(using: name, email: email).on { _  in
                    let creds = Credentials(name: name, email: email)
                    try? Storage.credentails.save(creds)
                } failure: { error in
                    Logger.logError(error)
                    self.render(state: .error(error))
                }
            } else {
                guard let message = layoutableView.messageField.text else {
                    render(state: .error(AnyError(message: "Message field is empty")))
                    return
                }
                let creds = Credentials(name: name, email: email)
                try? Storage.credentails.save(creds)
                self.render(state: .loading)
                let customFields = layoutableView.customFieldsArray.toDictionary()
                
                viewModel.sendOfflineMessage(message, customFields: customFields, with: creds).on { _ in
                    self.render(state: .showingData)
                } failure: { error in
                    self.render(state: .error(error))
                }
                
            }
        }
    }
    
    @discardableResult
    func validate() -> Bool {
        let email = layoutableView.emailTextField.text?.trim() ?? ""
        let name = layoutableView.nameTextField.text?.trim() ?? ""
        let message = layoutableView.messageField.text?.trim() ?? ""
        
        typealias TextValidator = Validator<String, String>
        var validator = TextValidator()
        
        layoutableView.messageErrorLabel.isHidden = true
        layoutableView.nameTextField.isValid = true
        layoutableView.emailTextField.isValid = true
        layoutableView.customFieldsArray.forEach { $0.isValid = true }
        
        let emailField = TextValidator.InputFiled(input: email, rulues: [.notEmpty, .email], output: { error in
            self.layoutableView.emailTextField.errorMessage = error
        })
        
        let nameField = TextValidator.InputFiled(input: name, rulues: [.notEmpty], output: { error in
            self.layoutableView.nameTextField.errorMessage = error
        })
        
        let messageField = TextValidator.InputFiled(input: message, rulues: [.notEmpty], output: { error in
            self.layoutableView.messageErrorLabel.text = error
            self.layoutableView.messageErrorLabel.isHidden = false
        })
        
        let customFields: [TextValidator.InputFiled] = layoutableView.customFieldsArray.map { tf in
            .init(input: tf.text ?? "", rulues: tf.validators, output: { error in
                tf.errorMessage = error
            })
        }
        
        validator.add(fields: [emailField, nameField])
        if !viewModel.isOnline {
            validator.add(fields: [messageField] + customFields)
        }
        
        return validator.batchValidation()
    }
}

fileprivate extension Array where Element == ValidatableField {
    func toDictionary() -> [String: String] {
        var dict = [String: String]()
        for element in self {
            dict[element.key] = element.text ?? ""
        }
        return dict
    }
}

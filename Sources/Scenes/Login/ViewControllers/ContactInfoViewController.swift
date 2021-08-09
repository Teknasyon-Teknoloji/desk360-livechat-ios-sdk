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
        if let cred = Storage.credentails.object {
            layoutableView.emailTextField.text = cred.email
            layoutableView.nameTextField.text = cred.name
        }
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
	}
}

// MARK: - View Helpers
private extension ContactInfoViewController {
	func listenForUIEvents() {
		layoutableView.nameTextField.addTarget(
			self,
			action: #selector(textFieldTextDidChange),
			for: .editingChanged
		)
		
        layoutableView.emailTextField.addTarget(
            self,
            action: #selector(textFieldTextDidChange),
            for: .editingChanged
        )
        
        layoutableView.messageField.delegate = self
        
		layoutableView.startChatButton.addTarget(
			self,
			action: #selector(didTapSubmitButton),
			for: .touchUpInside
		)
		
		layoutableView.chatAgentView.backButton.action = viewModel.back
	}
}

extension ContactInfoViewController: GrowingTextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        layoutableView.messageErrorLabel.isHidden = !textView.text.trim().isEmpty
    }
}

// MARK: - Actions
private extension ContactInfoViewController {
	@objc func textFieldTextDidChange(_ sender: UITextField) {
		if sender == layoutableView.nameTextField {
            let count = layoutableView.nameTextField.text?.count ?? 0
            layoutableView.nameFieldLimit.text = count < 10 ? "0\(count)/50" : "\(count)/50"
            layoutableView.nameErrorLabel.isHidden = !(sender.text?.trim().isEmpty ?? true)
		} else if sender == layoutableView.emailTextField {
            layoutableView.emailErrorLabel.isHidden = !(sender.text?.trim().isEmpty ?? true)
		}
	}
	
	@objc func didTapSubmitButton() {
		if validate() {
			let email = layoutableView.emailTextField.text ?? ""
			let name = layoutableView.nameTextField.text ?? ""
			if viewModel.isOnline {
				self.render(state: .loading)
			
				viewModel.login(using: name, email: email).on { _  in
					//	self.render(state: .showingData)
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
                viewModel.sendOfflineMessage(message, with: creds).on { _ in
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
		
		layoutableView.emailErrorLabel.isHidden = true
		layoutableView.nameErrorLabel.isHidden = true
		layoutableView.messageErrorLabel.isHidden = true
		
		let emailField = TextValidator.InputFiled(input: email, rulues: [.notEmpty, .email], output: { error in
			self.layoutableView.emailErrorLabel.isHidden = false
			self.layoutableView.emailErrorLabel.text = error
		})
		
		let nameField = TextValidator.InputFiled(input: name, rulues: [.notEmpty], output: { error in
			self.layoutableView.nameErrorLabel.isHidden = false
			self.layoutableView.nameErrorLabel.text = error
		})
		
		let messageField = TextValidator.InputFiled(input: message, rulues: [.notEmpty], output: { error in
			self.layoutableView.messageErrorLabel.text = error
			self.layoutableView.messageErrorLabel.isHidden = false
		})
		
		validator.add(fields: [emailField, nameField])
		if !viewModel.isOnline {
			validator.add(field: messageField)
		}
		
		return validator.batchValidation()
	}
}

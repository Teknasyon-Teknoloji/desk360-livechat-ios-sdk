//
//  ChatViewController.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 27.04.2021.
//

import Photos
import QuickLook
import UIKit

final class ChatViewController: BaseViewController, Layouting, ViewModelIntializing, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, MessagesDataSource {
	
	typealias ViewType 	= ChatView
	typealias ViewModel = ChatViewModel
	
	let viewModel: ViewModel
	
	var curretItem: ChatMediaItem?
	
	private var messages: [MessageSection] = []
    private var seenMessages = Set<MessageCellViewModel>()
    private var shouldShowBadge = false
    
	private lazy var picker = Picker(presenter: self)
	private lazy var chatView =  ChatInputView()
    
	private var isMessagesControllerBeingDismissed: Bool = false
	private var scrollsToLastItemOnKeyboardBeginsEditing: Bool = false
	private var scrollsToBottomOnKeyboardBeginsEditing: Bool = false
	private var maintainPositionOnKeyboardFrameChanged: Bool = false
    private let debouncer = Debouncer(delay: 0.5)
    
    private var isSendButtonEnabled: Bool {
        viewModel.isConnected && !chatView.textView.text.trim().isEmpty
    }
    
	private var messageCollectionViewBottomInset: CGFloat = 0 {
		didSet {
			layoutableView.collectionView.contentInset.bottom = messageCollectionViewBottomInset
			layoutableView.collectionView.scrollIndicatorInsets.bottom = messageCollectionViewBottomInset
		}
	}
	
	private var additionalBottomInset: CGFloat = 0 {
		didSet {
			let delta = additionalBottomInset - oldValue
			messageCollectionViewBottomInset += delta
		}
	}
	
	required init(viewModel: ViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	@available(*, unavailable, message: "init(coder:) has not been implemented")
	required init?(coder: NSCoder) { fatalError() }
	
	override func loadView() {
		view = ViewType.create()
	}
	
	var isFirstLayout = true
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		UIApplication.shared.statusBarUIView?.backgroundColor = config?.general.backgroundHeaderColor.uiColor
        viewModel.shouldRecieveNotifications(false)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		isMessagesControllerBeingDismissed = true
        navigationItem.hidesBackButton = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.isHidden = true
        viewModel.shouldRecieveNotifications(true)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		isMessagesControllerBeingDismissed = false
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()
		// messageCollectionViewBottomInset = requiredInitialScrollViewBottomInset()
	}
	
	override var inputAccessoryView: UIView? {
		chatView
	}
	
	override var canBecomeFirstResponder: Bool {
		true
	}
	
	override var canResignFirstResponder: Bool {
		true
	}
	
	override func setupAppearnace() {
		super.setupAppearnace()
		chatView.sendButton.isEnabled = false
        let topInset = navigationController?.navigationBar.frame.height ?? .zero
		let bottomInset = chatView.frame.height
		layoutableView.collectionView.contentInset = .init(top: -topInset + 15, left: 0, bottom: bottomInset, right: 0)
        layoutableView.backgroundColor = .white
	}
	
	override func bindUIControls() {
		super.bindUIControls()
		setupDelegates()
		layoutableView.agentView.configure(with: viewModel.agent)
		chatView.attachmentButton.addTarget(self, action: #selector(addFile), for: .touchUpInside)
		chatView.sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
		chatView.textView.trimWhiteSpaceWhenEndEditing = true
		chatView.textView.delegate = self
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
		
		layoutableView.endChatAction = {
            self.layoutableView.agentView.optionsButton.isEnabled = false
			self.viewModel.endChat().on { _ in
                self.layoutableView.agentView.optionsButton.isEnabled = true
			} failure: { error in
                self.layoutableView.agentView.optionsButton.isEnabled = true
				Logger.logError(error)
			}
		}
		
		layoutableView.sendTranscriptAction = {
			self.viewModel.prepareTranscript()
		}
		
		layoutableView.agentView.backButton.action = viewModel.back
        
        layoutableView.recentMessagesBadge.action = {
            self.layoutableView.collectionView.scrollToLastItem()
        }
	}
    
	override func bindViewModel() {
		super.bindViewModel()
		viewModel.receive { _ in
			self.messages = self.viewModel.messages
			self.layoutableView.collectionView.layoutIfNeeded()
			self.layoutableView.collectionView.reloadData()
            if self.isFirstLayout {
                self.layoutableView.collectionView.scrollToLastItem(at: .bottom, animated: !self.isFirstLayout)
                self.layoutableView.hideBadgeView()
                self.messages.flatMap { $0.messages }.forEach { self.seenMessages.insert($0) }
                
            } else {
                self.showBadgeIfNeeded()
            }
           // self.layoutableView.collectionView.scrollToLastItem(at: .bottom, animated: !self.isFirstLayout)
            //Logger.log(event: .info, "Offset: \(self.layoutableView.collectionView.contentOffset)")
//			for op in changedIndices {
//				switch op {
//				case let .insert(indexPath):
//					if firsReload {
//						self.layoutableView.collectionView.reloadData()
//                        self.layoutableView.collectionView.scrollToLastItem(at: .bottom, animated: !self.isFirstLayout)
//					} else {
//						UIView.performWithoutAnimation {
//							self.layoutableView.collectionView.insertItems(at: [indexPath])
//							self.layoutableView.collectionView.scrollToLastItem(at: .bottom, animated: !self.isFirstLayout)
//
//					}
//                }
//                case let .update(indexpath):
//					UIView.performWithoutAnimation {
//						self.layoutableView.collectionView.reloadItems(at: [indexpath])
//					}
//				}
//			}
                
			self.isFirstLayout = false
        }
        
		viewModel.reload = {
			self.messages = self.viewModel.messages
			self.layoutableView.collectionView.reloadData()
			self.layoutableView.collectionView.scrollToLastItem()
		}
		
		viewModel.agentHandler = { newAgent in
			if let isShowNameActive = Storage.settings.object?.config.online.showAgentName,
			   isShowNameActive {
				self.layoutableView.agentView.configure(with: newAgent)
			}
		}
		
		viewModel.listenForTypingEvents { _ in
            guard config?.chat.typingStatus == true else { return }
            
            self.layoutableView.agentView.typingInfolabel.text = Strings.online_typing
            self.debouncer.run {
                Flow.delay(for: 1) {
                    self.layoutableView.agentView.typingInfolabel.text = self.viewModel.agent?.receivingStatus.localizedValue
                }
            }
			
		}
        
        viewModel.checkConnectivity { status in
            self.chatView.sendButton.isEnabled = self.isSendButtonEnabled
            switch status {
            case .reachable:
                self.layoutableView.connectivityLabel.isHidden = true
            case .notReachable:
                self.layoutableView.connectivityLabel.isHidden = false
            case .unknown:
                self.layoutableView.connectivityLabel.isHidden = false
            }
        }
	}
	
    func showBadgeIfNeeded() {
        if shouldShowBadge {
            let total = messages.flatMap { $0.messages }.count
            let unseenMessagesCount = total - seenMessages.count
            if layoutableView.recentMessagesBadge.isHidden {
                layoutableView.showBadgeView(withValue: unseenMessagesCount)
            } else {
                layoutableView.updateBadgeView(withValue: unseenMessagesCount)
            }
        } else {
            layoutableView.hideBadgeView()
            layoutableView.collectionView.scrollToLastItem(at: .bottom, animated: !isFirstLayout)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        shouldShowBadge = distanceFromBottom < height
        if distanceFromBottom < height {
            shouldShowBadge = false
            layoutableView.hideBadgeView(animated: false)
        } else {
            shouldShowBadge = true
        }
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
       
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
    }
    
	@objc private func adjustForKeyboard(notification: Notification) {
		guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
		
		let keyboardScreenEndFrame = keyboardValue.cgRectValue
		let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
		
		if notification.name == UIResponder.keyboardWillHideNotification {
            let topInset = navigationController?.navigationBar.frame.height ?? .zero
            let bottomInset: CGFloat = 0
            layoutableView.collectionView.contentInset = .init(top: 15, left: 0, bottom: bottomInset, right: 0)
            layoutableView.connectivityLabel.transform = .identity
		} else {
			layoutableView.collectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
            layoutableView.connectivityLabel.transform = .init(translationX: 0, y: -(keyboardViewEndFrame.height - view.safeAreaInsets.bottom - chatView.frame.height))
		}
       
		layoutableView.collectionView.scrollIndicatorInsets = layoutableView.collectionView.contentInset
	}

    func resignKeyboard() {
        self.chatView.resignFirstResponder()
        self.layoutableView.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        resignKeyboard()
    }
    
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		messages.count
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		messages[section].messages.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let collectionView = collectionView as? MessagesCollectionView else { fatalError() }
		return cellForMessage(at: indexPath, collectionView: collectionView)
	}
	
	func cellForMessage(at indexPath: IndexPath, collectionView: MessagesCollectionView) -> ChatBaseCell {
		let messaage = messages[indexPath.section].messages[indexPath.item]
        var cell: ChatBaseCell
		switch messaage.message.kind {
		case .attributedText, .text, .emoji:
			let aCell = collectionView.dequeueReusableCell(ChatTextMessageCell.self, for: indexPath)
            cell = aCell
		case .video:
			if messaage.isSentSuccessfully {
				let aCell = collectionView.dequeueReusableCell(ChatVideoMessageCell.self, for: indexPath)
                cell = aCell
			} else {
				let aCell = collectionView.dequeueReusableCell(ChatErrorVideoCell.self, for: indexPath)
                cell = aCell
			}
		case .photo:
			let aCell = collectionView.dequeueReusableCell(ChatImageMessageCell.self, for: indexPath)
            cell = aCell
		case .document:
			let aCell = collectionView.dequeueReusableCell(ChatDocumentMessageCell.self, for: indexPath)
            cell = aCell
		case .linkPreview:
			fatalError()
        }
        cell.configure(with: messaage)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.messageLabel.delegate = self
        cell.delegate = self
        return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
		let message = messages[indexPath.section].messages[indexPath.item]
		
		switch message.message.kind {
		case .text, .attributedText, .emoji, .photo:
			return true
		default:
			return false
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
		(action == NSSelectorFromString("copy:"))
	}
	
	func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
		
		let pasteBoard = UIPasteboard.general
		let message = messages[indexPath.section].messages[indexPath.item]
		
		switch message.message.kind {
		case .text(let text), .emoji(let text):
			pasteBoard.string = text
		case .attributedText(let attributedText):
			pasteBoard.string = attributedText.string
		case .photo(let mediaItem):
			pasteBoard.image = mediaItem.image ?? mediaItem.placeholderImage
		default:
			break
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		guard let messagesFlowLayout = collectionViewLayout as? MessagesCollectionViewFlowLayout else { return .zero }
		return messagesFlowLayout.sizeForItem(at: indexPath)
	}
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let message = messages[indexPath.section].messages[indexPath.item]
        message.isSeen = true
        seenMessages.insert(message)
    }
    
	func messageForItem(at indexPath: IndexPath) -> MessageCellViewModel {
		return messages[indexPath.section].messages[indexPath.item]
	}
	
	func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
		messages.count
	}
	
	func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
		messages.count
	}
	
	@objc func didTapSendButton() {
		guard let text = chatView.textView.text else { return }
		let type: MessageKind = text.isEmoji ? .emoji(text) : .text(text)
		viewModel.send(message: type) { _ in
            self.messages = self.viewModel.messages
            self.layoutableView.collectionView.reloadData()
            self.layoutableView.collectionView.scrollToLastItem()
			self.chatView.sendButton.isEnabled = false
			self.chatView.textView.text = nil
		}
	}
}

private extension ChatViewController {
	func setupDelegates() {
		layoutableView.collectionView.delegate = self
		layoutableView.collectionView.dataSource = self
		layoutableView.collectionView.messagesDataSource = self
	}
	
	@objc func addFile() {
		layoutableView.endEditing(true)
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
        let showImagePicker = UIAlertAction(title: "\(Strings.sdk_image)/ \(Strings.sdk_video)", style: .default) { _ in
			self.picker.pick(from: .media) { fileName, fileType in
				Logger.log(event: .success, "Did pick a \(fileName)", fileType)
				if case .video(let item) = fileType {
					self.viewModel.send(message: .video(item)) { _ in }
				} else {
					self.viewModel.send(message: .photo(fileType.item )) { _ in
						
					}
				}
			}
		}
		
        let showFilePicker = UIAlertAction(title: Strings.sdk_choose_document, style: .default) { _ in
			self.picker.pick(from: .document) { fileName, fileType in
				self.viewModel.send(message: .document(fileType.item)) { _ in
					
				}
			}
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		
		if #available(iOS 11.0, *) {
			alert.addAction(showFilePicker)
		}
		
		alert.addAction(showImagePicker)
		alert.addAction(cancelAction)
		
		present(alert, animated: true)
	}
}

extension String {
	var isEmoji: Bool {
		EmojiDetector.shared.isEmoji(character: self)
	}
}

extension ChatViewController: MessageCellDelegate {
	func didTapImage(in cell: ChatBaseCell, image: UIImage?) {
		guard let image = image else { return }
		let imageInfo      = GSImageInfo(image: image, imageMode: .aspectFit, imageHD: nil)
		let transitionInfo = GSTransitionInfo(fromView: cell)
		let imageViewer    = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
		present(imageViewer, animated: true, completion: nil)
	}
	
	func didTapFile(in cell: ChatBaseCell, file item: ChatMediaItem?) {
		guard let item = item else { return }
		curretItem = item
		let previewController = QLPreviewController()
		previewController.dataSource = self
		previewController.delegate = self
		previewController.modalPresentationStyle = .fullScreen
		//	present(previewController, animated: true)
		navigationController?.pushViewController(previewController, animated: true)
		UIApplication.shared.statusBarUIView?.backgroundColor = previewController.navigationController?.navigationBar.backgroundColor
		
	}
	
	func didTapVideo(in cell: ChatBaseCell, video item: ChatMediaItem?) {
		guard let item = item, let url = item.localUrl else { return }
        let player = VGVerticalViewController(url: url)
		self.navigationController?.pushViewController(player, animated: true)
	}
	
	func didSelectDate(_ date: Date) {
		
	}
	
	func didSelectURL(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}
	
	func didSelectPhoneNumber(_ phoneNumber: String) {
        if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
	}
}

extension ChatViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
	func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
		1
	}
	
	func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
		guard let item = curretItem, let url = item.localUrl else { fatalError() }
		return url as QLPreviewItem
	}
}

extension ChatViewController: GrowingTextViewDelegate {
	
	func textViewDidBeginEditing(_ textView: UITextView) {
        chatView.sendButton.isEnabled = isSendButtonEnabled
	}
	
	func textViewDidChange(_ textView: UITextView) {
        chatView.sendButton.isEnabled = isSendButtonEnabled
		viewModel.sendTypingEvents()
	}
}

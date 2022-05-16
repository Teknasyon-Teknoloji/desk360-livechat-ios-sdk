//
//  CannedResponseViewController.swift
//  Desk360LiveChat
//
//  Created by Alper Tabak on 23.02.2022.
//

import UIKit

final class CannedResponseViewController: BaseViewController, Layouting, ViewModelIntializing {
	
	typealias ViewType = CannedResponseView
	typealias ViewModel = CannedResponseViewModel
    
    private var sizes: [IndexPath: CGSize] = [:]
    private var attributes: [IndexPath: NSAttributedString] = [:]
	
	override func loadView() {
		view = ViewType.create()
	}
	
	internal let viewModel: ViewModel
	public required init(viewModel: ViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        layoutableView.collectionView.isUserInteractionEnabled = false
		viewModel.delegate = self
		layoutableView.collectionView.dataSource = self
		layoutableView.collectionView.delegate = self
		layoutableView.collectionView.messagesDataSource = self
		layoutableView.agentView.backButton.action = viewModel.back
		layoutableView.agentView.configure(with: nil)
        self.viewModel.start()
        
		viewModel.statusHandler = { [weak self] status in
			guard let self = self else { return }
			self.render(state: status)
		}
		
		viewModel.resetHandler = { [weak self] in
			guard let self = self else { return }
			self.attributes.removeAll()
			self.sizes.removeAll()
		}
	}
	
	private func buttonTapped(with element: ResponseElement) {
		self.viewModel.setSelectedUnit(for: element)
		self.layoutableView.collectionView.isUserInteractionEnabled = false
		guard element.actionableType == .path else { return }
		self.viewModel.goToPath(id: element.actionableID ?? 0)
	}
	
	private func surveyTapped(with result: CannedResponseSurveyType) {
		Logger.log(event: .success, result)
		PopupManager.shared.show(
			popupType: .success,
			on: self,
			title: "",
			message: Strings.canned_response_feedback_success_title) { [weak self] in
				guard let self = self else { return }
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
					self.viewModel.back()
				}
			}
		self.viewModel.sendFeedback(for: result)
	}
	
	private func closeButtonTaped(with element: ResponseElement) {
		self.viewModel.setSelectedUnit(for: element)
		switch element.actionableType {
		case .returnStartPath:
			self.viewModel.returnToStartPosition()
		case .closeAndSurvey:
			self.viewModel.arrangeSurvey()
		case .liveHelp:
			viewModel.operateChatScreen()
		default:
			return
		}
	}
    
    var isLayouting = false
	
}

extension CannedResponseViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsIn(section: section)
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let collectionView = collectionView as? MessagesCollectionView else { fatalError() }
		guard let cell = cellForMessage(at: indexPath, collectionView: collectionView) else { fatalError() }
		return cell
	}
	
	func cellForMessage(at indexPath: IndexPath, collectionView: MessagesCollectionView) -> ChatBaseCell? {
		var cell: ChatBaseCell?
		guard let response = viewModel.getGroupedUnits(for: indexPath) else { return nil }
			
		if response.id == -1 {
			let aCell = collectionView.dequeueReusableCell(CannedResponseSurveyCell.self, for: indexPath)
			aCell.tapHandler = surveyTapped(with:)
			cell = aCell
			return cell
		}
		
		switch response.type {
		case .button:
			let aCell = collectionView.dequeueReusableCell(CannedResponseButtonCell.self, for: indexPath)
			aCell.item = response
			aCell.tag = indexPath.row
			aCell.tapHandler = buttonTapped(with:)
			aCell.currentIndex = indexPath
            aCell.latestIndex = IndexPath(item: self.viewModel.latestUnitIndex, section: self.viewModel.sections.count - 1)
			cell = aCell
		
		case .closeMenuButton:
			let aCell = collectionView.dequeueReusableCell(CannedResponseCloseCell.self, for: indexPath)
			aCell.item = response
			aCell.delegate = self
			aCell.tapHandler = self.closeButtonTaped(with:)
            aCell.currentIndex = indexPath
            aCell.latestIndex = IndexPath(item: self.viewModel.latestUnitIndex, section: self.viewModel.sections.count - 1)
            aCell.setNeedsLayout()
            aCell.layoutIfNeeded()
			cell = aCell
			
		case .message:
			let aCell = collectionView.dequeueReusableCell(ChatTextMessageCell.self, for: indexPath)
			let message = response.generateMessage(for: false)
			aCell.messageLabel.delegate = self
			aCell.cannedResponseActive = true
			//aCell.cannedResonseConfigure(with: .init(message: message))
			aCell.configure(with: .init(message: message))
			if let attribute = CannedResponseAttributeCollector.shared.attribute(for: response.id) {
                DispatchQueue.main.async {
                    aCell.messageLabel.attributedText = attribute.attribute
                    aCell.messageLabel.font = FontFamily.Gotham.book.font(size: 16)
                    aCell.messageLabel.textColor = .black
                    aCell.setNeedsLayout()
                    aCell.layoutIfNeeded()
                }
			}
			
            /*if self.attributes.keys.contains(indexPath), let attribute = self.attributes[indexPath] {
                aCell.messageLabel.attributedText = attribute
                aCell.messageLabel.font = FontFamily.Gotham.book.font(size: 16)
                aCell.messageLabel.textColor = .black
            } else {
                let attributes = message.content.htmlToAttributedString
                aCell.messageLabel.attributedText = attributes
                aCell.messageLabel.font = FontFamily.Gotham.book.font(size: 16)
                aCell.messageLabel.textColor = .black
				self.attributes[indexPath] = attributes
                
            }*/
			cell = aCell
			
		default:
			break
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let size = self.sizes[indexPath], size != .zero {
            return size
        }
        
        var returnSize: CGSize = .zero
        defer {
            if returnSize != .zero {
                self.sizes[indexPath] = returnSize
            }
        }
		
		guard let messagesFlowLayout = collectionViewLayout as? MessagesCollectionViewFlowLayout else { return .zero }
		
		if let response = viewModel.getGroupedUnits(for: indexPath), response.id == -1 {
			let size = messagesFlowLayout.sizeForItem(at: indexPath)
			returnSize = .init(width: collectionView.bounds.size.width - 20, height: 100 + size.height)
            return returnSize
        }
		
		if let response = viewModel.getGroupedUnits(for: indexPath), response.type != .message {
			returnSize = .init(width: collectionView.bounds.size.width - 20, height: 48)
            return returnSize
        }
			
		messagesFlowLayout.layoutForCannedResponse(value: true)
		returnSize =  messagesFlowLayout.sizeForItem(at: indexPath)
		return returnSize
	}
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sections.count
    }
    
    
}

extension CannedResponseViewController: MessagesDataSource {
	
	func messageForItem(at indexPath: IndexPath) -> MessageCellViewModel {
		guard let item = viewModel.getGroupedUnits(for: indexPath) else {
			return .init(message: .init())
		}
		let message = item.generateMessage(for: false)
		return .init(message: message)
	}
	
	func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
		return 1
	}
	
	func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
		return 0
	}
	
}

extension CannedResponseViewController: CannedResponseViewModelDelegate {
    
    func basicReload() {
        self.layoutableView.collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.layoutableView.collectionView.isUserInteractionEnabled = true
        }

        //self.layoutableView.isUserInteractionEnabled = true
    }
	    
    func reload() {
        guard !isLayouting else { return }
        Logger.log(event: .success, "LAYOUTING")
        self.isLayouting = true
        
		let collectionView = layoutableView.collectionView
        DispatchQueue.main.async {
            collectionView.reloadData()
        }
        
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 6.2, initialSpringVelocity: 2.2, options: .curveEaseInOut) {
            DispatchQueue.main.async {
                collectionView.setNeedsLayout()
                collectionView.layoutIfNeeded()
            }
        } completion: { _ in
            collectionView.scrollToLastItem(at: .bottom, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                collectionView.isUserInteractionEnabled = true
                self.isLayouting = false
            }
        }
	}
		
}

extension CannedResponseViewController: MessageCellDelegate, MessageLabelDelegate {
	
	func didSelectURL(_ url: URL) {
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}
	
}

//
//  ChatDocumentMessageCell.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 10.06.2021.
//

import UIKit

final class ChatDocumentMessageCell: ChatBaseCell {
	
	lazy var fileFormatIcon: UIImageView = {
		let imageView = UIImageView()
		imageView.image = Images.aviIcon.withRenderingMode(.alwaysOriginal)
		imageView.setSize(.init(width: 35, height: 40))
		return imageView
	}()
	
	lazy var fileName: UILabel = {
		let label = UILabel()
		label.text = "Desk360.avi"
		label.textColor = .white
		label.font = FontFamily.Gotham.book.font(size: 14)
		return label
	}()
	
	lazy var downloadButton: NFDownloadButton = {
		let button = NFDownloadButton(type: .system)
		button.setSize(.init(width: 50, height: 50))
		button.addTarget(self, action: #selector(didTapDownload), for: .touchUpInside)
        button.initialColor = config?.general.backgroundHeaderColor.uiColor
		button.downloadState = .toDownload
        button.tintColor = config?.general.backgroundHeaderColor.uiColor
		return button
	}()
	
	lazy var circleProgressView: CircleProgressView = {
		let view = CircleProgressView()
		view.backgroundColor = bubbleView.backgroundColor
		view.progressColor = .white
		view.setSize(.init(width: 50, height: 50))
		view.layer.cornerRadius = 6
		view.progress = 0
		view.isHidden = true
        view.progressColor = config?.general.backgroundHeaderColor.uiColor ?? .blue
		return view
	}()
	
	lazy var progressLabel: UILabel = {
		let label = UILabel()
        label.text = Strings.sdk_uploading
		label.textColor = .blue
		label.font = FontFamily.Gotham.book.font(size: 10)
		label.textAlignment = .right
		return label
	}()
	
    override func setuptextColors(_ color: UIColor?) {
        super.setuptextColors(color)
        fileName.textColor = color
        progressLabel.textColor = config?.general.backgroundHeaderColor.uiColor
    }
    
	lazy var progressContainer: UIView = {
		let view = UIView()
		view.addSubview(progressBarView)
		view.addSubview(progressLabel)
	//	view.backgroundColor = .red
		return view
	}()
	
	lazy var progressBarView: BarProgressView = {
		let view = BarProgressView()
		view.backgroundColor = bubbleView.backgroundColor
		view.progressColor = .dodgerBlue
		view.progress = 0
		view.isHidden = true
		// view.backgroundColor = .red
		return view
	}()
	
	lazy var fileStack: UIView = .hStack(
		alignment: .center,
		distribution: .equalCentering,
		spacing: 8,
		[
			fileFormatIcon,
			fileName,
			.spacer(),
			.spacer(),
			downloadButton,
			circleProgressView
		]
	)
	
	override func setupViews() {
		super.setupViews()
		bubbleView.addSubview(fileStack)
		addSubview(progressContainer)
        bubbleView.addSubview(messageLabel)
	}
	
	override func layoutViews() {
		super.layoutViews()
    
        if let vm = viewModel, vm.message.content.isEmpty == false {
            messageLabel.text = vm.message.content
            messageLabel.anchor(
                top: nil,
                leading: bubbleView.leadingAnchor,
                bottom: bubbleView.bottomAnchor,
                trailing: bubbleView.trailingAnchor,
                padding: .init(v: 10, h: 10)
            )
            
            fileStack.anchor(
                top: bubbleView.topAnchor,
                leading: bubbleView.leadingAnchor,
                bottom: messageLabel.topAnchor,
                trailing: bubbleView.trailingAnchor,
                padding: .init(v: 0, h: 10),
                size: .init(width: 0, height: 50)
            )
           
            tickAndTimeStack.removeFromSuperview()
            messageLabel.addSubview(tickAndTimeStack)
            
            let lineWidth = messageLabel.lastLineWidth
            bringSubviewToFront(tickAndTimeStack)
                    
            if lineWidth <= bubbleView.frame.width * 0.8 && messageLabel.numberOfLines > 1 {
                tickAndTimeStack.anchor(
                    top: nil,
                    leading: messageLabel.trailingAnchor,
                    bottom: messageLabel.bottomAnchor,
                    trailing: bubbleView.trailingAnchor,
                    padding: .init(top: 4, left: 8, bottom: 0, right: 4)
                )
            } else {
                let extraInset: CGFloat = 4
                tickAndTimeStack.anchor(
                    top: nil,
                    leading: nil,
                    bottom: bubbleView.bottomAnchor,
                    trailing: messageLabel.trailingAnchor,
                    padding: .init(top: -12, left: 8, bottom: 8, right: 4 + extraInset)
                )
            }
            
        } else {
            fileStack.anchor(
                top: bubbleView.topAnchor,
                leading: bubbleView.leadingAnchor,
                bottom: bubbleView.bottomAnchor,
                trailing: bubbleView.trailingAnchor,
                padding: .init(v: 10, h: 10)
            )
            
            tickAndTimeStack.anchor(
                    top: nil,
                    leading: nil,
                    bottom: bubbleView.bottomAnchor,
                    trailing: bubbleView.trailingAnchor,
                    padding: .init(top: 2, left: 0, bottom: 6, right: 14)
                )
        }
        
		progressContainer.anchor(
            top: bubbleView.bottomAnchor,
            leading: bubbleView.leadingAnchor,
            bottom: nil,
            trailing: bubbleView.trailingAnchor,
            padding: .init(top: 8, left: 10, bottom: 10, right: 10),
            size: .init(width: bubbleView.frame.width, height: 40)
        )
		
		progressBarView
            .anchor(
                top: progressContainer.topAnchor,
                leading: progressContainer.leadingAnchor,
                bottom: nil,
                trailing: progressContainer.trailingAnchor,
                padding: .init(v: 10, h: 10),
                size: .init(width: bubbleView.frame.width, height: 2.5)
            )
		
		progressLabel.anchor(
            top: progressBarView.bottomAnchor,
            leading: progressBarView.leadingAnchor,
            bottom: progressContainer.bottomAnchor,
            trailing: progressContainer.trailingAnchor,
            padding: .init(v: 4, h: 10)
        )
	}

    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = ""
        fileName.text = ""
        fileFormatIcon.image = nil
        tickView.image = nil
    }
    
	override func configure(with viewModel: MessageCellViewModel) {
		super.configure(with: viewModel)
		if let attac = viewModel.message.attachment {
			if let doc = attac.mapToMessageType(), case let .document(item) = doc {
				fileName.text = item.fileName
			}
		} else {
			fileName.text = viewModel.message.mediaItem?.fileName
		}
		
		downloadButton.isHidden = viewModel.isCached
		
		if let attac = viewModel.message.attachment {
			if let doc = attac.mapToMessageType(), case let .document(item) = doc {
				fileName.text = item.fileName
				fileFormatIcon.image = item.thumbnail
			}
		} else {
			fileName.text = viewModel.message.mediaItem?.fileName
			fileFormatIcon.image = viewModel.message.mediaItem?.thumbnail
		}
        tickView.image = viewModel.state.image
		dateLabel.isHidden = viewModel.isUploading
        tickView.isHidden = viewModel.isUploading || viewModel.isIncomingMessage
        progressBarView.isHidden = !viewModel.isUploading // viewModel.state != .sending
		progressContainer .isHidden = !viewModel.isUploading // viewModel.state != .sending
        tickView.isHidden = viewModel.isUploading || viewModel.isIncomingMessage
		viewModel.uploadProgress = { progress in
			self.progressBarView.progress = progress
//			if progress >= 1 {
//				Flow.delay(for: 0.5) {
//					self.progressBarView.isHidden = true
//					self.progressContainer .isHidden = true
//				}
//			}
		}
		
	}
	
	@objc private func didTapDownload() {
		if viewModel?.isCached  ?? false {
			return
		}
		
		downloadButton.isHidden = true
		circleProgressView.isHidden = false
		
		viewModel?.downloadFile(progress: { progress in
			self.circleProgressView.progress = CGFloat(progress.fractionCompleted)
		}, completion: { result in
			switch result {
			case .success:
				self.circleProgressView.isHidden = true
			case .failure(let error):
				Logger.logError(error)
			}
		})
	}
	
	override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        super.handleTapGesture(gesture)
		guard viewModel?.isUploading == false || viewModel?.isDownloading == false else { return }
		guard viewModel?.isCached == true else {
			didTapDownload()
			return
		}
		
		var item: ChatMediaItem
		if let aItem = viewModel?.mediaItem {
			item = aItem
		} else if let bItem = viewModel?.cachedMediaItem {
			item = bItem
		} else {
			return
		}
		delegate?.didTapFile(in: self, file: item)
	}
}

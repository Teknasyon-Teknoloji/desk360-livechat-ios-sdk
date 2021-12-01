//
//  ChatMediaMessageCell.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 14.05.2021.
//

import Kingfisher
import Photos
import UIKit

class ChatVideoMessageCell: ChatBaseCell {
	
	lazy var videoIcon: UIImageView = {
		let imageView = UIImageView()
		imageView.image = Images.videoIcon.withRenderingMode(.alwaysOriginal)
		imageView.setSize(.init(width: 44, height: 44))
		return imageView
	}()
	
	lazy var topContainer: UIImageView = {
		let view = UIImageView()
		view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
		view.layer.cornerRadius = 8
		view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
		return view
	}()
	
	lazy var fileFormatIcon: UIImageView = {
		let imageView = UIImageView()
		imageView.image = Images.aviIcon.withRenderingMode(.alwaysOriginal)
		imageView.setSize(.init(width: 26, height: 30))
		return imageView
	}()
	
	lazy var fileName: PaddingLabel = {
		let label = PaddingLabel()
		label.text = ""
		label.textColor = .white
		label.font = FontFamily.Gotham.book.font(size: 14)
        label.clipsToBounds = true
		return label
	}()
	
	lazy var playButton: UIButton = {
		let button = UIButton(type: .system)
		button.setSize(.init(width: 50, height: 50))
		button.addTarget(self, action: #selector(didTapDownload), for: .touchUpInside)
		button.setImage(Images.play, for: .normal)
		button.isHidden = true
		return button
	}()
	
	lazy var circleProgressView: CircleProgressView = {
		let view = CircleProgressView()
		view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
		view.progressColor = .white
		view.setSize(.init(width: 50, height: 50))
		view.layer.cornerRadius = 6
		view.progress = 0
		view.isHidden = true
		return view
	}()
	
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
    
	lazy var fileStack: UIView = .hStack(
		alignment: .fill,
		distribution: .fill,
		spacing: 8,
		[
			fileFormatIcon,
			fileName,
			.spacer()
		]
	)
	
	override func setupViews() {
		super.setupViews()
		bubbleView.addSubview(topContainer)
		topContainer.addSubview(videoIcon)
		bubbleView.addSubview(fileStack)
		topContainer.addSubview(playButton)
		topContainer.addSubview(circleProgressView)
		addSubview(progressContainer)
        bubbleView.addSubview(messageLabel)
        fileStack.clipsToBounds = true
	}
	
	override func layoutViews() {
		super.layoutViews()
        topContainer.setSize(.init(width: 0, height: 110))
        if let vm = viewModel, vm.message.content.isEmpty == false {
            messageLabel.text = vm.message.content
            messageLabel.anchor(top: nil, leading: bubbleView.leadingAnchor, bottom: bubbleView.bottomAnchor, trailing: bubbleView.trailingAnchor, padding: .init(v: 10, h: 10))
            
            fileStack.anchor(
                top: topContainer.bottomAnchor,
                leading: bubbleView.leadingAnchor,
                bottom: messageLabel.topAnchor,
                trailing: trailingAnchor,
                padding: .init(top: 10, left: 10, bottom: 10, right: 10)
            )
            
        } else {
            fileStack.anchor(
                top: topContainer.bottomAnchor,
                leading: bubbleView.leadingAnchor,
                bottom: nil,
                trailing: tickView.leadingAnchor,
                padding: .init(top: 10, left: 10, bottom: 10, right: 2)
            )
        }
        
		// tickView.setSize(.init(width: 12, height: 12))
		tickAndTimeStack.anchor(
            top: nil,
            leading: nil,
            bottom: bubbleView.bottomAnchor,
            trailing: bubbleView.trailingAnchor,
            padding: .init(top: 0, left: 0, bottom: 8, right: 8)
        )
		
		topContainer.anchor(
			top: bubbleView.topAnchor,
			leading: bubbleView.leadingAnchor,
			bottom: nil,
			trailing: bubbleView.trailingAnchor,
			padding: .init(v: 10, h: 10)
		)
		
		videoIcon.centerInSuperview()
		circleProgressView.centerInSuperview()
		playButton.centerInSuperview()
				
        progressContainer.anchor(
            top: bubbleView.bottomAnchor,
            leading: bubbleView.leadingAnchor,
            bottom: nil,
            trailing: bubbleView.trailingAnchor,
            padding: .init(top: 8, left: 10, bottom: 10, right: 10),
            size: .init(width: bubbleView.frame.width, height: 40)
        )
		
		progressBarView.anchor(top: progressContainer.topAnchor, leading: progressContainer.leadingAnchor, bottom: nil, trailing: progressContainer.trailingAnchor, padding: .init(v: 10, h: 10), size: .init(width: bubbleView.frame.width, height: 2.5))
		
		progressLabel.anchor(top: progressBarView.bottomAnchor, leading: progressBarView.leadingAnchor, bottom: progressContainer.bottomAnchor, trailing: progressContainer.trailingAnchor, padding: .init(v: 4, h: 10))
	}
	
	override func configure(with viewModel: MessageCellViewModel) {
		super.configure(with: viewModel)
		viewModel.uploadProgress = { progrss in
			self.progressBarView.progress = progrss
		}
		
		if let url = getMediaUrlFromMessage(viewModel.message) {
			if ImageCache.default.isCached(forKey: url.absoluteString) {
				ImageCache.default.retrieveImage(forKey: url.absoluteString) { result in
					switch result {
					case let .success(image):
						print(image)
						self.topContainer.image = image.image
					case let .failure(error):
						print(error)
					}
				}
			} else {
				getThumbnailImage(fromURL: url) { image in
					ImageCache.default.store(image ?? UIImage(), original: image?.pngData(), forKey: url.absoluteString, toDisk: true)
					self.topContainer.image = image
				}
			}
			
			videoIcon.isHidden = viewModel.isCached
			playButton.isHidden = !viewModel.isCached
		}
		
		if let attac = viewModel.message.attachment {
			if let doc = attac.mapToMessageType(), case let .video(item) = doc {
				fileName.text = item.fileName
				fileFormatIcon.image = item.thumbnail
			}
		} else {
			fileName.text = viewModel.message.mediaItem?.fileName
			fileFormatIcon.image = viewModel.message.mediaItem?.thumbnail
		}
		
        dateLabel.isHidden = viewModel.isUploading
        progressBarView.isHidden = !viewModel.isUploading
        progressContainer .isHidden = !viewModel.isUploading
        tickView.isHidden = viewModel.isUploading || viewModel.isIncomingMessage
	}
	
	@objc private func didTapDownload() {
		if viewModel?.isCached  ?? false {
			return
		}
		
		circleProgressView.isHidden = false
		videoIcon.isHidden = true
		playButton.isHidden = true
		
		viewModel?.downloadFile(progress: { progress in
			self.circleProgressView.progress = CGFloat(progress.fractionCompleted)
		}, completion: { result in
			switch result {
			case .success(let item):
				self.circleProgressView.isHidden = true
				self.videoIcon.isHidden = true
				self.playButton.isHidden = false
			case .failure(let error):
				Logger.logError(error)
			}
			
		})
	}
	
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = ""
        topContainer.image = nil
        fileName.text = ""
        fileFormatIcon.image = nil
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
		
		delegate?.didTapVideo(in: self, video: item)
	}
	
	func requestAuthorization(completion: @escaping () -> Void) {
		if PHPhotoLibrary.authorizationStatus() == .notDetermined {
			PHPhotoLibrary.requestAuthorization { (_) in
				DispatchQueue.main.async {
					completion()
				}
			}
		} else if PHPhotoLibrary.authorizationStatus() == .authorized {
			completion()
		}
	}
	
	func saveVideoToAlbum(_ outputURL: URL, _ completion: ((Error?) -> Void)?) {
		requestAuthorization {
			PHPhotoLibrary.shared().performChanges({
				let request = PHAssetCreationRequest.forAsset()
				request.addResource(with: .video, fileURL: outputURL, options: nil)
			}) { (_, error) in
				DispatchQueue.main.async {
					if let error = error {
						print(error.localizedDescription)
					} else {
						print("Saved successfully")
					}
					completion?(error)
				}
			}
		}
	}
	
	func getThumbnailImage(fromURL url: URL, completion: @escaping ((_ image: UIImage?) -> Void)) {
		DispatchQueue.global().async {
			let asset = AVAsset(url: url)
			let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
			avAssetImageGenerator.appliesPreferredTrackTransform = true
			let thumnailTime = CMTimeMake(value: 2, timescale: 1)
			do {
				let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
				let thumbImage = UIImage(cgImage: cgThumbImage)
				DispatchQueue.main.async {
					completion(thumbImage)
				}
			} catch {
				print(error.localizedDescription)
				DispatchQueue.main.async {
					completion(nil)
				}
			}
		}
	}
	
	func getMediaUrlFromMessage(_ message: Message) -> URL? {
		var url: URL?
		if let attachment = message.attachment {
			let urlString = attachment.videos?.first?.url
			url = URL(string: urlString ?? "")
		} else {
			url = message.mediaItem?.localUrl ?? message.mediaItem?.url
		}
		
		return url
	}
}

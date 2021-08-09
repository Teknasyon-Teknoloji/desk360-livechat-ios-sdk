//
//  ChatImageMessageCell.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 9.06.2021.
//

import Kingfisher
import NVActivityIndicatorView
import UIKit

final class ChatImageMessageCell: ChatBaseCell {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var blurView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var previewView: UIImageView = {
        let view = UIImageView()
        view.setSize(.init(width: 44, height: 44))
        view.contentMode = .scaleAspectFit
        view.image = Images.imagepreview
        view.isHidden = true
        return view
    }()
    
    //	lazy var circleProgressView: CircleProgressView = {
    //		let view = CircleProgressView()
    //		view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    //		view.progressColor = .white
    //		view.setSize(.init(width: 50, height: 50))
    //		view.layer.cornerRadius = 6
    //		return view
    //	}()
    //
    private lazy var loadingIndicator: NVActivityIndicatorView = {
        let view = NVActivityIndicatorView(frame: .init(origin: .zero, size: .init(width: 50, height: 50)), type: .circleStrokeSpin, color: .white, padding: .zero)
        return view
    }()
    
    override func configure(with viewModel: MessageCellViewModel) {
        super.configure(with: viewModel)
        if viewModel.state == .sending {
            imageView.image = viewModel.message.mediaItem?.image
            loadingIndicator.startAnimating()
        }
        
        if let attachmet = viewModel.message.attachment, let url = URL(string: attachmet.images?.first?.url ?? "") {
            imageView.kf.setImage(with: url, placeholder: viewModel.message.mediaItem?.image) { _ in
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.previewView.isHidden = false
                }
            }
        }
    }
    
    override func setupViews() {
        super.setupViews()
        bubbleView.addSubview(imageView)
        bubbleView.addSubview(blurView)
        bubbleView.addSubview(loadingIndicator)
        bubbleView.addSubview(previewView)
        bubbleView.addSubview(messageLabel)
        //		bubbleView.addSubview(circleProgressView)
    }
    
    override func layoutViews() {
        super.layoutViews()
        imageView.heightAnchor.constraint(equalToConstant: 155).isActive = true
        imageView.anchor(
            top: bubbleView.topAnchor,
            leading: bubbleView.leadingAnchor,
            bottom: nil,
            trailing: bubbleView.trailingAnchor,
            padding: .init(top: 10, left: 10, bottom: 10, right: 10)
        )
        
        if let vm = viewModel, vm.message.content.isEmpty == false {
            messageLabel.text = vm.message.content
            
            messageLabel.anchor(
                top: imageView.bottomAnchor,
                leading: bubbleView.leadingAnchor,
                bottom: bubbleView.bottomAnchor,
                trailing: bubbleView.trailingAnchor,
                padding: .init(v: 10, h: 10)
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
            if !(viewModel?.message.content.isEmpty ?? true) { return }
            tickAndTimeStack.anchor(
                top: nil,
                leading: nil,
                bottom: bubbleView.bottomAnchor,
                trailing: bubbleView.trailingAnchor,
                padding: .init(top: 0, left: 0, bottom: 4, right: 12)
            )
            // imageView.fillSuperview(padding: .init(top: 10, left: 10, bottom: 20, right: 10))
        }
        
        // blurView.fillSuperview()
        
        loadingIndicator.centerXTo(imageView.centerXAnchor)
        loadingIndicator.centerYTo(imageView.centerYAnchor)
        
        previewView.centerXTo(imageView.centerXAnchor)
        previewView.centerYTo(imageView.centerYAnchor)
        //		circleProgressView.centerInSuperview()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = ""
        imageView.image = nil
    }
    
    override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        super.handleTapGesture(gesture)
        let touchLocation = gesture.location(in: imageView)
        
        guard imageView.frame.contains(touchLocation) else {
            super.handleTapGesture(gesture)
            return
        }
        
        guard viewModel?.state != .sending else { return }
        delegate?.didTapImage(in: self, image: imageView.image)
    }
}

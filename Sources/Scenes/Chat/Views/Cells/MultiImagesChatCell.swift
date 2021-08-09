//
//  MultiImagesChatCell.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 29.07.2021.
//

import Kingfisher
import NVActivityIndicatorView
import UIKit

final class MultiImagesChatCell: ChatBaseCell {
    
    lazy var multipleImagesCollection: MultipleItemsCollection = {
        let collectionView = MultipleItemsCollection(items: [])
        return collectionView
    }()
    
    private lazy var loadingIndicator: NVActivityIndicatorView = {
        let view = NVActivityIndicatorView(
            frame: .init(origin: .zero, size: .init(width: 50, height: 50)),
            type: .circleStrokeSpin, color: .white, padding: .zero
        )
        return view
    }()
    
    override func configure(with viewModel: MessageCellViewModel) {
        super.configure(with: viewModel)
        if viewModel.state == .sending {
            // imageView.image = viewModel.message.mediaItem?.image
            loadingIndicator.startAnimating()
        }
        
        if let attachmet = viewModel.message.attachment, let url = URL(string: attachmet.images?.first?.url ?? "") {
//            imageView.kf.setImage(with: url, placeholder: viewModel.message.mediaItem?.image) { _ in
//                DispatchQueue.main.async {
//                    self.loadingIndicator.stopAnimating()
//                    self.previewView.isHidden = false
//                }
//            }
        }
    }
    
    override func setupViews() {
        super.setupViews()
        bubbleView.addSubview(multipleImagesCollection)
        bubbleView.addSubview(loadingIndicator)
        addSubview(messageLabel)
//        bubbleView.addSubview(circleProgressView)
    }
    
    override func layoutViews() {
        super.layoutViews()
        if let vm = viewModel, vm.message.content.isEmpty == false {
            messageLabel.text = vm.message.content
            messageLabel.anchor(top: nil, leading: bubbleView.leadingAnchor, bottom: bubbleView.bottomAnchor, trailing: bubbleView.trailingAnchor, padding: .init(v: 10, h: 10))
            multipleImagesCollection.anchor(top: bubbleView.topAnchor, leading: bubbleView.leadingAnchor, bottom: messageLabel.topAnchor, trailing: bubbleView.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 10, right: 10))
            multipleImagesCollection.heightAnchor.constraint(equalToConstant: 155).isActive = true
        } else {
            multipleImagesCollection.fillSuperview(padding: .init(top: 10, left: 10, bottom: 20, right: 10))
        }
        
        loadingIndicator.centerXTo(multipleImagesCollection.centerXAnchor)
        loadingIndicator.centerYTo(multipleImagesCollection.centerYAnchor)
        
        tickAndTimeStack.anchor(
            top: nil,
            leading: nil,
            bottom: bubbleView.bottomAnchor,
            trailing: bubbleView.trailingAnchor,
            padding: .init(top: 0, left: 0, bottom: 4, right: 8)
        )
    }
    
    override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        super.handleTapGesture(gesture)
//        let touchLocation = gesture.location(in: multipleImagesCollection)
//
//        guard multipleImagesCollection.frame.contains(touchLocation) else {
//            super.handleTapGesture(gesture)
//            return
//        }
//
//        guard viewModel?.state != .sending else { return }
//        delegate?.didTapImage(in: self, image: imageView.image)
    }
}

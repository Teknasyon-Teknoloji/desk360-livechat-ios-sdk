//
//  SessionTerminationView.swift
//  Example
//
//  Created by Ali Ammar Hilal on 18.06.2021.
//

import UIKit

final class SessionTerminationView: UIView, Layoutable {
	
	lazy var agentView: ChatAgentView = {
		ChatAgentView.create()
	}()
	
	private lazy var messageTitle: UILabel = {
		let label = UILabel()
		label.font = FontFamily.Gotham.medium.font(size: 20)
		label.text = config?.feedback.headerTitle
		label.textAlignment = .center
        label.textColor = config?.general.sectionHeaderTextColor.uiColor
		return label
	}()
	
	private lazy var feedbackLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.font = FontFamily.Gotham.book.font(size: 16)
		label.text = config?.feedback.headerText
        label.textColor = config?.general.sectionHeaderTitleColor.uiColor
		label.clipsToBounds = true
		label.textAlignment = .center
		return label
	}()
	
	private lazy var feedbackSuccessLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.font = FontFamily.Gotham.book.font(size: 16)
		label.text = Strings.feedback_success_title
		label.clipsToBounds = true
		label.textAlignment = .center
		label.isHidden = true
		return label
	}()
	
	lazy var likeButton: UIButton = {
		let button = UIButton(type: .system)
		button.backgroundColor = config?.feedback.iconUpColor.uiColor
		button.layer.cornerRadius = 36
		button.setImage(Images.thumbsUp, for: .normal)
		return button
	}()
	
	lazy var dislikeButton: UIButton = {
		let button = UIButton(type: .system)
		button.backgroundColor = config?.feedback.iconDownColor.uiColor
		button.layer.cornerRadius = 36
		button.setImage(Images.thumbsDown, for: .normal)
		return button
	}()
	
	private lazy var transcriptLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.font = FontFamily.Gotham.book.font(size: 16)
		label.text = config?.feedback.bottomText
		label.clipsToBounds = true
		label.textAlignment = .center
		return label
	}()
	
	lazy var transcriptButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle(Strings.feedbackBottomLink, for: .normal)
		button.setTitleColor(config?.feedback.bottomLinkColor.uiColor, for: .normal)
		button.layer.cornerRadius = 22
		button.titleLabel?.font = FontFamily.Gotham.medium.font(size: 14)
		return button
	}()
	
	lazy var textStack: UIView = .vStack(
		alignment: .center,
		distribution: .fill,
		spacing: 10,
		[
			messageTitle,
			feedbackLabel
		]
	)
	
	lazy var ratingStack: UIView = .hStack(
		alignment: .center,
		distribution: .equalCentering,
		spacing: 10,
		[
			.spacer(),
			.spacer(),
			dislikeButton,
			.spacer(),
			likeButton,
			.spacer(),
			.spacer()
		]
	)
	
	lazy var transcriptStack: UIView = .vStack(
		alignment: .center,
		distribution: .fill,
		spacing: 10,
		[
			transcriptLabel,
			transcriptButton
		]
	)
	
	lazy var startNewChatButton: ActionButton = {
		let button = ActionButton(type: .system)
		button.layer.cornerRadius = 22
		button.setTitle(Strings.feedback_button, for: .normal)
		button.backgroundColor = config?.general.sendButtonBackgroundColor.uiColor
		button.setTitleColor(config?.general.sendButtonTextColor.uiColor, for: .normal)
		return button
	}()
	
	override func layoutSubviews() {
		super.layoutSubviews()
		addSubview(agentView)
		addSubview(textStack)
		addSubview(ratingStack)
		// addSubview(transcriptStack)
		addSubview(startNewChatButton)
		addSubview(feedbackSuccessLabel)
		
		likeButton.setSize(.init(width: 74, height: 74))
		dislikeButton.setSize(.init(width: 74, height: 74))
		
		agentView.anchor(
			top: safeAreaLayoutGuide.topAnchor,
			leading: leadingAnchor,
			bottom: nil,
			trailing: trailingAnchor
		)
		
		textStack.anchor(
			top: agentView.bottomAnchor,
			leading: leadingAnchor,
			bottom: nil,
			trailing: trailingAnchor,
			padding: .init(v: 50, h: 20)
		)
		
		feedbackSuccessLabel.anchor(
			top: textStack.bottomAnchor,
			leading: leadingAnchor,
			bottom: nil,
			trailing: trailingAnchor,
			padding: .init(v: 40, h: 20)
		)
		
		ratingStack.anchor(
			top: textStack.bottomAnchor,
			leading: leadingAnchor,
			bottom: nil,
			trailing: trailingAnchor,
			padding: .init(v: 20, h: 20)
		)
		
//		transcriptStack.anchor(
//			top: ratingStack.bottomAnchor,
//			leading: leadingAnchor,
//			bottom: nil,
//			trailing: trailingAnchor,
//			padding: .init(v: 20, h: 20)
//		)
		
		startNewChatButton.centerXToSuperview()
		startNewChatButton.anchor(
			top: ratingStack.bottomAnchor,
			padding: .init(v: 45, h: 0),
			size: .init(width: frame.width * 0.75, height: 44)
		)
        
        sendSubviewToBack(startNewChatButton)
	}
	
	func setupViews() {
		agentView.optionsButton.isHidden = true
	}
	
	func setupLayout() { }
	
	func animateRating(tappedButton: UIButton) {
		tappedButton.scaleDown {
			tappedButton.scaleUp {
				tappedButton.reset {
					self.ratingStack.isHidden = true
					self.showRatingSuccess()
				}
			}
		}
	}
	
	func didRateSuccefully() {
		
	}
	
	func showRatingSuccess() {
		feedbackSuccessLabel.alpha = 0.1
		feedbackSuccessLabel.transform = .init(translationX: 0, y: 50)
		UIView.animate(withDuration: 0.3, delay: 0, options: []) {
			self.feedbackSuccessLabel.alpha = 1
			self.feedbackSuccessLabel.isHidden = false
			self.feedbackSuccessLabel.transform = .identity
			self.layoutIfNeeded()
		} completion: { _ in
			
		}

	}
}

extension UIView {
	
	func scaleDown(completion: (@escaping() -> Void)) {
		UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
			let scaleTransform: CGAffineTransform = CGAffineTransform(scaleX: 0.75, y: 0.75)
			self.transform = scaleTransform
		} completion: { _ in
			completion()
		}
	}
	
	func scaleUp(completion: (@escaping() -> Void)) {
		UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
			let scaleTransform: CGAffineTransform = CGAffineTransform(scaleX: 1.25, y: 1.25)
			self.transform = scaleTransform
		} completion: { _ in
			completion()
		}
	}
	
	func reset(completion: (@escaping() -> Void)) {
		UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
			self.transform = .identity
		} completion: { _ in
			completion()
		}
	}
	
	func shake(duration: CFTimeInterval) {
		let translation = CAKeyframeAnimation(keyPath: "transform.translation.x")
		translation.timingFunction = CAMediaTimingFunction(name: .linear)
		translation.values = [-5, 5, -5, 5, -3, 3, -2, 2, 0]
		
		let rotation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
		rotation.values = [-5, 5, -5, 5, -3, 3, -2, 2, 0].map { (degrees: Double) -> Double in
			let radians: Double = (.pi * degrees) / 180.0
			return radians
		}
		
		let shakeGroup: CAAnimationGroup = CAAnimationGroup()
		shakeGroup.animations = [translation, rotation]
		shakeGroup.duration = duration
		self.layer.add(shakeGroup, forKey: "shakeIt")
	}
	
	func animateWithHeartBeat(delay: TimeInterval, duration: TimeInterval) {
		let shrinkDuration: TimeInterval = duration * 0.5
		UIView.animate(withDuration: shrinkDuration,
					   delay: delay,
					   usingSpringWithDamping: 0.7,
					   initialSpringVelocity: 10,
					   options: [],
					   animations: {
						let scaleTransform: CGAffineTransform = CGAffineTransform(scaleX: 0.75, y: 0.75)
						self.transform = scaleTransform
					   })
	}
	
	func animateWithZoomOut() {
		let growDuration: TimeInterval =  2 * 0.3
		UIView.animate(withDuration: growDuration, animations: {
			self.transform = self.getZoomOutTranform()
			self.alpha = 0
		}, completion: { _ in
			self.removeFromSuperview()
		})
	}
	
	func getZoomOutTranform() -> CGAffineTransform {
		let zoomOutTranform: CGAffineTransform = CGAffineTransform(scaleX: 20, y: 20)
		return zoomOutTranform
	}
}

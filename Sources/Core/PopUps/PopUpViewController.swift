//
//  PopUpManager.swift
//  Adjust
//
//  Created by Ali Ammar Hilal on 13.07.2021.
//

import UIKit

struct PopupConfiguration {
    let blurEffectStyle: UIBlurEffect.Style? = nil
    let initialScaleAmmount: CGFloat = 0.3
    let animationDuration: TimeInterval = 0.3
}

final class PopUpViewController: UIViewController {
    
    var popupView: PopupView
    
    init(kind: PopupType, message: String) {
        self.popupView = PopupView(kind: kind, message: message)
        super.init(nibName: nil, bundle: nil)
    }
	

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(popupView)
        view.backgroundColor = .clear
        popupView.centerInSuperview()
    }
}

class PopupView: UIView {
    private let kind: PopupType
    
    private lazy var popupTypeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var popupMessagelabel: UILabel = {
        let label = UILabel()
        label.font = FontFamily.Gotham.book.font(size: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.clipsToBounds = true
        return label
    }()
    
    lazy var actionButton: ActionButton = {
        let button = ActionButton(type: .system)
        button.backgroundColor = config?.general.backgroundHeaderColor.uiColor
        button.setTitleColor(config?.general.sendButtonTextColor.uiColor, for: .normal)
        button.layer.cornerRadius = 20
        button.setTitle(Strings.sdk_ok, for: .normal)
        return button
    }()
	
	lazy var cancelButton: ActionButton = {
		let button = ActionButton(type: .system)
		button.backgroundColor = config?.general.backgroundHeaderColor.uiColor
		button.setTitleColor(config?.general.sendButtonTextColor.uiColor, for: .normal)
		button.layer.cornerRadius = 20
		button.setTitle("Cancel", for: .normal)
		return button
	}()
    
    override var intrinsicContentSize: CGSize {
        let width = UIScreen.main.bounds.width * 0.8
        let textHeight = popupMessagelabel.text?.size(constraintedWidth: width).height ?? .zero
        let height = popupTypeIcon.frame.height + textHeight + 44 + 44
        return .init(width: width, height: height)
    }
	
	private lazy var hStack: UIStackView = .hStack(
		alignment: .fill,
		distribution: .fillEqually,
		spacing: 4,
		[
			cancelButton, actionButton
		])

    private lazy var stackView: UIStackView = .vStack(
        alignment: .center,
        distribution: .fill,
        spacing: 10,
        [
            popupTypeIcon,
            popupMessagelabel,
            .spacer()
        ]
    )
    
    init(kind: PopupType, message: String) {
        self.kind = kind
        super.init(frame: .zero)
		if kind == .cancellable {
			self.stackView.addArrangedSubview(hStack)
			self.actionButton.setTitle(Strings.confirmation_end_conversation_button_yes, for: .normal)
			self.cancelButton.setTitle(Strings.confirmation_end_conversation_button_no, for: .normal)
		} else {
			self.stackView.addArrangedSubview(actionButton)
		}
		
        self.popupMessagelabel.text = message
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8).isActive = true
        layer.cornerRadius = 8
        clipsToBounds = true
        backgroundColor = .white
        if #available(iOS 13.0, *) {
            popupTypeIcon.image = kind.image.withTintColor(config?.general.backgroundHeaderColor.uiColor ?? .cadetBlue)
        } else {
            // Fallback on earlier versions
        }
        actionButton.setSize(.init(width: frame.width * 0.9, height: 44))
		actionButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addSubview(stackView)
        stackView.fillSuperview(padding: .init(v: 12, h: 12))
    }
}

enum PopupType {
    case info
    case noInternet
    case error
    case success
	case cancellable
    
    var image: UIImage {
        switch self {
		case .error, .info, .cancellable:
           return Images.info
        case .success:
            return Images.success
        case .noInternet:
			return Images.noInternet
        }
    }
}

final class PopupManager: NSObject {
    
    static var shared = PopupManager()
    
    private var visualEffectBlurView = ContextMenuBackgroundBlurView(.light)
    private var isPresenting = false
    private var configuration = PopupConfiguration()
    
	func show(popupType: PopupType, on parentViewController: UIViewController, title: String, message: String, action: (() -> Void)?, cancelAction: (() -> Void)? = nil) {
        let viewControllerToPresent = PopUpViewController(kind: popupType, message: message)
        viewControllerToPresent.modalPresentationStyle = .overCurrentContext
        viewControllerToPresent.transitioningDelegate = self
        viewControllerToPresent.popupView.popupMessagelabel.text = message
        viewControllerToPresent.popupView.actionButton.action = {
            action?()
            viewControllerToPresent.dismiss(animated: true)
        }
		
		if let cancelAction = cancelAction {
			viewControllerToPresent.popupView.cancelButton.action = {
				viewControllerToPresent.dismiss(animated: true)
			}
		}
		
        
        parentViewController.present(viewControllerToPresent, animated: true, completion: nil)
    }
    
    private func animatePresent(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let presentedViewController = transitionContext.viewController(forKey: .to),
            let presentedControllerDelegate = presentedViewController as? PopUpViewController
        else { return }
        
        presentedViewController.view.alpha = 0
        presentedViewController.view.frame = transitionContext.containerView.bounds
        
        transitionContext.containerView.addSubview(presentedViewController.view)
        
        if let blurEffectStyle = configuration.blurEffectStyle {
            visualEffectBlurView.frame = transitionContext.containerView.bounds
            visualEffectBlurView.alpha = 1
            
            transitionContext.containerView.insertSubview(visualEffectBlurView, at: 0)
            visualEffectBlurView.fillSuperview()
            
            // blur view animation workaround: need that to avoid the "blur-flashes"
            UIView.animate(withDuration: transitionDuration(using: transitionContext) * 0.25) {
                self.visualEffectBlurView.effect = UIBlurEffect(style: blurEffectStyle)
            }
        } else {
            presentedControllerDelegate.view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        }
        
        presentedControllerDelegate.popupView.alpha = 0
        presentedControllerDelegate.popupView.transform = CGAffineTransform(
            scaleX: configuration.initialScaleAmmount,
            y: configuration.initialScaleAmmount
        )
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
            options: .allowUserInteraction,
            animations: {
                presentedViewController.view.alpha = 1
                presentedControllerDelegate.popupView.alpha = 1
                presentedControllerDelegate.popupView.transform = CGAffineTransform(scaleX: 1, y: 1)
            },
            completion: { isCompleted in
                transitionContext.completeTransition(isCompleted)
            }
        )
    }
    
    fileprivate func animateDismiss(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let presentedViewController = transitionContext.viewController(forKey: .from),
            let presentedControllerDelegate = presentedViewController as? PopUpViewController
        else { return }
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            usingSpringWithDamping: 2,
            initialSpringVelocity: 0.0,
            options: .allowUserInteraction,
            animations: {
                presentedViewController.view.alpha = 0
                self.visualEffectBlurView.alpha = 0
                presentedControllerDelegate.popupView.transform = CGAffineTransform(
                    scaleX: self.configuration.initialScaleAmmount,
                    y: self.configuration.initialScaleAmmount
                )
            },
            completion: { isCompleted in
                self.visualEffectBlurView.effect = nil
                self.visualEffectBlurView.removeFromSuperview()
                transitionContext.completeTransition(isCompleted)
            }
        )
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate
extension PopupManager: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
}

// MARK: - UIViewControllerAnimatedTransitioning
extension PopupManager: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        if let toViewControllerDelegate = transitionContext?.viewController(forKey: .to) as? PopUpManager {
//            return configuration.animationDuration
//        }
//        if let fromViewControllerDelegate = transitionContext?.viewController(forKey: .from) as? PopUpManager {
//            return configuration.animationDuration
//        }
//        return 0
        return configuration.animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            animatePresent(transitionContext: transitionContext)
        } else {
            animateDismiss(transitionContext: transitionContext)
        }
    }
    
}

//
//  AppCoordinator.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 26.04.2021.
//

import FirebaseAuth
import FirebaseCore
import UIKit

enum MainRoute: Route {
	case bootstrap
	case intro
	case login(isOnline: Bool)
    case chat(agent: Agent?, user: Credentials, delegate: ChatDeletgate? = nil)
	case cannedResponse
	case offlineMessage
	case sessionTermination(agent: Agent?, sessionId: String? = nil)
	case transcript
	case pop
	case dismiss
	case popToRoot
    case close
}

final class AppCoordinator: Coordinator<MainRoute> {

	private let credentials: Credentials?
	private let smartPlug: SmartPlug?
	private let factory: ProvidersFactory
	private let presenter: UIViewController
	
	init(
		credentials: Credentials?,
		smartPlug: SmartPlug? = nil,
		factory: ProvidersFactory,
		presenter: UIViewController
	) {
		self.credentials = credentials
		self.smartPlug = smartPlug
		self.factory = factory
		self.presenter = presenter
		super.init(router: Router())
		
		self.router.navigationController.modalPresentationStyle = .fullScreen
		presenter.present(self.router.navigationController, animated: true, completion: nil)
		self.router.navigationController.navigationBar.isHidden = true
	}
	
	// swiftlint:disable function_body_length
	override func trigger(_ route: MainRoute?) {
		guard let route = route else { return }
		switch route {
		case .bootstrap:
			let bootstrappingViewModel = BootstrappingViewModel(
				router: self,
				settingsProvider: factory.makeSettingsProvider(),
				credentials: credentials,
                loginProvider: factory.makeLoginProvider(),
                agentProvider: factory.makeAgentProvider()
			)
			
			let bootstrappingViewController = BootstrappingViewController(viewModel: bootstrappingViewModel)
			router.push(bootstrappingViewController, animated: false, completion: nil)
			
		case .intro:
			let mainViewModel = MainViewModel(
				router: self,
				agentProvider: factory.makeAgentProvider(),
				credentails: credentials,
				loginProvider: factory.makeLoginProvider() 
			)
			mainViewModel.smartPlugs = self.smartPlug
			
			let mainVc = MainViewController(viewModel: mainViewModel)
			router.setRootModule(mainVc, hideBar: true)
			
		case .login(let isOnline):
			let loginViewModel = ContactInfoViewModel(
				router: self,
				loginProvider: factory.makeLoginProvider(),
				credentials: credentials,
				smartPlug: self.smartPlug,
				agentProvider: factory.makeAgentProvider(),
				messageProvider: factory.makeMessagingProvider(),
				isOnline: isOnline
			)
			
			let loginViewController = ContactInfoViewController(viewModel: loginViewModel)
            
			router.push(loginViewController, animated: true, completion: nil)
			
		case .chat(let agent, let user, let delegate):
			// guard let credentials = credentials else { return }
			let chattingViewModel = ChatViewModel(
				router: self,
				agent: agent,
				messageProvider: factory.makeMessagingProvider(),
				fileUploader: factory.makeFileUploader(),
				sessionProvider: factory.makeSessionProvider(),
				credentials: user
			)
            chattingViewModel.delegate = delegate
            
			let chattingViewController = ChatViewController(viewModel: chattingViewModel)
			router.push(chattingViewController, animated: true, completion: nil)
			
		case .cannedResponse:
			let viewModel = CannedResponseViewModel(
				feedbackProvider: factory.makeFeedbackProvider(),
				agentProvider: factory.makeAgentProvider(),
				loginProvider: factory.makeLoginProvider(),
				router: self
			)
			let viewController = CannedResponseViewController(viewModel: viewModel)
			router.push(viewController, animated: true, completion: nil)
															  
		case .offlineMessage:
			let viewModel = OfflineMessageViewModel(router: self)
			let offlineMessageVC = OfflineMessageViewController(viewModel: viewModel)
			router.push(offlineMessageVC, animated: true, completion: nil)
			
		case .sessionTermination(let agent, let sessionId):
            if UIApplication.topViewController() is SessionTerminationViewController { return }
			let viewModel = SessionTerminationViewModel(
				router: self,
				feedbackProvider: factory.makeFeedbackProvider(),
				loginProvider: factory.makeLoginProvider(),
				agentProvider: factory.makeAgentProvider(),
				credentials: credentials,
				smartPlugs: self.smartPlug,
				agent: agent,
				sessionId: sessionId
			)
			
			let viewController = SessionTerminationViewController(viewModel: viewModel)
			router.push(viewController, animated: true, completion: nil)
			
		case .transcript:
			let viewModel = TranscriptViewModel(router: self)
			let viewController = TranscriptViewController(viewModel: viewModel)
			router.push(viewController, animated: true, completion: nil)
			
		case .pop:
            router.rootViewController?.navigationController?.navigationBar.isHidden = true
            router.rootViewController?.navigationController?.setNavigationBarHidden(true, animated: true)
			router.popModule(animated: true)
			
		case .popToRoot:
            router.rootViewController?.navigationController?.navigationBar.isHidden = true
            router.rootViewController?.navigationController?.setNavigationBarHidden(true, animated: true)
			router.popToRootModule(animated: true)
			
		case .dismiss:
            UIApplication.shared.statusBarUIView?.backgroundColor = Desk360LiveChat.shared.defaultStatusBarColor
			router.dismiss(animated: true, completion: nil)
            
        case .close:
            UIApplication.shared.statusBarUIView?.backgroundColor = Desk360LiveChat.shared.defaultStatusBarColor
            router.dismiss(animated: true) {
                UIApplication.shared.statusBarUIView?.backgroundColor = Desk360LiveChat.shared.defaultStatusBarColor
            }
		}
	}

    private func listenForApplicationTermination() {
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: nil) { _ in
            UIApplication.shared.statusBarUIView?.backgroundColor = Desk360LiveChat.shared.defaultStatusBarColor
            if FirebaseApp.liveChatApp != nil {
                try? Auth.liveChat.signOut()
            }
            Session.activeConversation = nil
        }
    }
}

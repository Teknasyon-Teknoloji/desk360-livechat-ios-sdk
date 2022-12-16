//
//  SessionTerminationViewModel.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 18.06.2021.
//

import FirebaseAuth
import FirebaseCore
import Foundation

final class SessionTerminationViewModel {
    weak private var router: Coordinator<MainRoute>?
    private let feedbackProvider: FeedbackProvider
    private let loginProvider: LoginProvider
	private let agentProvider: AgentProvider
    
    let agent: Agent?
    let credentials: Credentials?
	private let smartPlugs: SmartPlug?
    var statusHandler: ((BaseViewController.State) -> Void)?
    private var isOnlineAgent = false
	private var sessionId: String?
	private var loginHandler: ((Agent?) -> Void)?
	private var onlineAgentCount = 0
	var redirectHandler: (() -> Void)?
    
    init(
        router: Coordinator<MainRoute>?,
        feedbackProvider: FeedbackProvider,
        loginProvider: LoginProvider,
		agentProvider: AgentProvider,
        credentials: Credentials?,
		smartPlugs: SmartPlug? = nil,
        agent: Agent?,
		sessionId: String? = nil
    ) {
        self.router = router
        self.feedbackProvider = feedbackProvider
        self.loginProvider = loginProvider
        self.agent = agent
        self.credentials = credentials
		self.smartPlugs = smartPlugs
		self.agentProvider = agentProvider
		self.sessionId = sessionId
        Flow.delay(for: 1.3) {
            Session.terminate(forceDeleteCreds: false)
        }
    }
    
    func prepareTranscript() {
        router?.trigger(.transcript)
    }
    
    func rate(with rating: Rating) -> Future<Void, Error> {
		defer {
			ChatViewModel.clearSessionId()
		}
		return feedbackProvider.rate(session: self.sessionId ?? "", with: rating.rawValue).map { _ in }
    }
    
    func startNewChat() {
        Session.terminate(forceDeleteCreds: false)
        var credentails: Credentials
        if let creds = self.credentials {
            credentails = creds
        } else if let creds = Storage.credentails.object {
            credentails = creds
        } else {
            self.backToRoot()
            return
        }
		
        let agentProvider = ProvidersFactory().makeAgentProvider()
        statusHandler?(.loading)
        Session
            .shared
			.login(using: credentails, smartPlug: self.smartPlugs)
            .flatMap { agentProvider.checkOnlineAgent(for: Storage.settings.object?.companyID ?? -1) }
            .map { self.isOnlineAgent = $0 }
            .flatMap { agentProvider.getOnlineAgentInfo(uid: Session.ID) }
            .on { [weak self] agent in
                guard let self = self else { return }
                self.statusHandler?(.showingData)
                if let agent = agent {
                    Session.activeConversation = RecentMessage(
                        agent: agent,
                        message: Message(
                            id: UUID.init().uuidString,
                            content: "",
                            createdAt: Date(),
                            updatedAt: Date(),
                            senderName: "",
                            agentID: agent.id,
                            status: .sent,
                            attachment: nil,
                            isCustomer: true, mediaItem: nil
                        )
                    )
                }
                if self.isOnlineAgent {
                    self.router?.trigger(.chat(agent: agent, user: credentails))
                } else {
                    self.router?.trigger(.login(isOnline: self.isOnlineAgent))
                }
            } failure: { [weak self]  error in
                self?.statusHandler?(.error(error))
            }
    }
	
	func triggerChatScreen() {
        Session.terminate(forceDeleteCreds: false)
        
		guard let credentials = getCredentails() else {
			self.presentChatOrLoginPage(for: nil)
			return
		}
		
		statusHandler?(.loading)

		getOnlineCountFromCompany { [weak self] onlineCount in
			guard let self = self else { return }
			
			guard onlineCount > 0 else {
				self.statusHandler?(.showingData)
				self.presentChatOrLoginPage(for: nil)
				return
			}
			self.login()
		}
		
		loginHandler = { [weak self] agent in
			guard let self = self else { return }
			self.statusHandler?(.showingData)
			
			guard let agent = agent else {
				self.router?.trigger(.chat(agent: nil, user: credentials, delegate: self))
				return
			}
			self.presentChatOrLoginPage(for: agent)
		}
	}
    
    func backToRoot() {
        Session.terminate()
        router?.trigger(.popToRoot)
    }
}

private extension SessionTerminationViewModel {
	
	func presentChatOrLoginPage(for agent: Agent?) {
		
		guard let agent = agent else {
			self.router?.trigger(.login(isOnline: false))
			return
		}
		
		guard let credentails = getCredentails() else {
			return
		}

		self.router?.trigger(.chat(agent: agent, user: credentails, delegate: self))
   }
	
	func getOnlineCountFromCompany(_ completion: @escaping (Int) -> Void) {
		let company = Storage.settings.object?.companyID ?? 0
		let application = Storage.settings.object?.applicationID ?? 0
		agentProvider.getOnlineAgentCount(for: company, applicationId: application)
			.on { onlineCount in
				self.onlineAgentCount = onlineCount ?? 0
				completion(self.onlineAgentCount)
			} failure: { error in
				Logger.log(event: .error, error)
				self.onlineAgentCount = 0
				
			}
	}
	
	private func getCredentails() -> Credentials? {
		var credentails: Credentials?
		if let creds = self.credentials {
			credentails = creds
		} else if let creds = Storage.credentails.object {
			credentails = creds
		}
		return credentails
	}
	
	
	
	func login() {
		guard let creds = getCredentails() else {
			return
		}
		Session.shared
			.startFlowWith(credentials: creds, smartPlug: self.smartPlugs)
			.flatMap(getOnlineAgent)
			.observe(on: .main)
			.on(success: { agent in
				self.loginHandler?(agent)
			})
	}
	
	func getOnlineAgent() -> Future<Agent?, Error> {
		let uid = Auth.liveChat.currentUser?.uid ?? ""
		return agentProvider.getOnlineAgentInfo(uid: uid)
	}
	
}

extension SessionTerminationViewModel: ChatDeletgate {
	func didRecieveNewMessage(_ newMessage: RecentMessage) {}
}

enum Rating: Int {
    case like = 1
	case dislike
}

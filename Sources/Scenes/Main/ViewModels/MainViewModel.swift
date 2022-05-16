//
//  MainViewModel.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 27.04.2021.
//

import FirebaseAuth
import Foundation
import FirebaseDatabase

final class MainViewModel {
	
	weak private var router: Coordinator<MainRoute>?
	private let agentProvider: AgentProvider
	
	private var onlineAgentCount = 0
	private var onlineAgentAvailable = false
	private var agent: Agent?
	private var credentails: Credentials?
	private let loginProvider: LoginProvider
	public var smartPlugs: SmartPlug?
	
	var statusHandler: ((BaseViewController.State) -> Void)?
    var refreshRecentMessages: ((RecentMessage) -> Void)?
    var redirectHandler: (() -> Void)?
	private var loginHandler: ((Agent?) -> Void)?
    
	init(
		router: Coordinator<MainRoute>,
		agentProvider: AgentProvider,
		credentails: Credentials?,
		loginProvider: LoginProvider
	) {
		self.router = router
		self.agentProvider = agentProvider
		self.credentails = credentails
		self.loginProvider = loginProvider
	}
	
	func fetchOnlineAgents() {
		let company = Storage.settings.object?.companyID ?? 0
		// statusHandler?(.loading)
		agentProvider
			.checkOnlineAgent(for: company)
		//	.flatMap(fetchAgentIf(isOnline:))
			.on { [weak self] isOnline in
                // self?.statusHandler?(.showingData)
				//	Logger.log(event: .success, agent)
                self?.onlineAgentAvailable = isOnline

			} failure: { error in
				// self?.onlineAgentAvailable = false
                self.statusHandler?(.error(error))
				self.agent = nil
				Logger.logError(error)
                if let token = Session.token {
                    _ = Session.shared.loginToFirebase(using: token)
                }
			}
	}
	
    func listenForAgentStatus() {
        guard let companyID = Storage.settings.object?.companyID else { return }
        guard let applicationID = Storage.settings.object?.applicationID else { return }
        let ref = Database.liveChatDB.reference(to: .online(companyID: companyID, applicationID: applicationID))
        ref.observe(.value) { snapshot  in
            let value = snapshot.value as? Int ?? 0
            if snapshot.exists() && value > 0 {
                self.onlineAgentAvailable = true
            } else {
                self.onlineAgentAvailable = false
            }
        }
    }
    	
	private func login() {
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
	
	 private func presentChatOrLoginPage(for agent: Agent?) {
		 
		 guard let agent = agent else {
			 self.router?.trigger(.login(isOnline: self.onlineAgentAvailable))
			 return
		 }
		 
		 guard let credentails = getCredentails() else {
			 return
		 }

		 self.router?.trigger(.chat(agent: agent, user: credentails, delegate: self))
	}
	
	func triggerChatScreen() {
        if let active = Session.activeConversation {
            self.presentChatOrLoginPage(for: active.agent)
            return
        }
		
		if let settings = Storage.settings.object, settings.isActiveCannedResponse {
            DispatchQueue.main.async {
                self.router?.trigger(.cannedResponse)
            }
            self.redirectHandler?()
			return
		}
		
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
	
	private func getOnlineCountFromCompany(_ completion: @escaping (Int) -> Void) {
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
        if let creds = self.credentails {
            credentails = creds
        } else if let creds = Storage.credentails.object {
            credentails = creds
        }
        return credentails
    }
	
	private func getOnlineAgent() -> Future<Agent?, Error> {
		let uid = Auth.liveChat.currentUser?.uid ?? ""
		return agentProvider.getOnlineAgentInfo(uid: uid)
	}
    
	// Normaly if the credentals are provided
	func reLogin(credentails: Credentials) {
		statusHandler?(.loading)
        Session
            .shared
            .login(using: credentails, smartPlug: nil).on { _ in
                self.statusHandler?(.showingData)
                guard let agent = self.agent else {
                   return
                }
                self.router?.trigger(.chat(agent: agent, user: credentails, delegate: self))
            } failure: { error in
                self.statusHandler?(.error(error))
            }

	}
	
//    func auth(_ token: Token) -> Future<Void, Error> {
//        let expirationDate = Calendar.current.date(byAdding: .hour, value: 24, to: Date())
//        try? Storage.expireDate.save(expirationDate)
//        try? Storage.token.save(token)
//        return self.loginProvider.authenticateSession(with: token)
//    }
    
	func fetchFaqs() -> [FaqSectionVM] {
		[
			
		]
	}
    
    func closeChat() {
        router?.trigger(.close)
    }
}

extension MainViewModel: ChatDeletgate {
    func didRecieveNewMessage(_ newMessage: RecentMessage) {
        refreshRecentMessages?(newMessage)
    }
}

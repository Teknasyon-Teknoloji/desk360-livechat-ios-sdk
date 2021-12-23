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
	
	private var onlineAgentAvailable = false
	private var agent: Agent?
	private var credentails: Credentials?
	private let loginProvider: LoginProvider
	
	var statusHandler: ((BaseViewController.State) -> Void)?
    var refreshRecentMessages: ((RecentMessage) -> Void)?
    
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
                    Session.shared.loginToFirebase(using: token)
                }
			}
	}
	
    func listenForAgentStatus() {
        guard let companyID = Storage.settings.object?.companyID else { return }
        let ref = Database.liveChatDB.reference(to: .online(companyID: companyID))
        ref.observe(.value) { snapshot  in
            let value = snapshot.value as? Int ?? 0
            if snapshot.exists() && value > 0 {
                self.onlineAgentAvailable = true
            } else {
                self.onlineAgentAvailable = false
            }
        }
    }
    
	private func fetchAgentIf(isOnline: Bool) -> Future<Agent?, Error> {
		self.onlineAgentAvailable = isOnline
		let uid = Auth.liveChat.currentUser?.uid ?? ""
		return agentProvider.getOnlineAgentInfo(uid: uid)
	}
	
	func triggerChatScreen() {
		
        if let active = Session.activeConversation {
            if let cred = getCredentails() {
                router?.trigger(.chat(agent: active.agent, user: cred, delegate: self))
                return
            }
        }
        
        router?.trigger(.login(isOnline: onlineAgentAvailable))
        
//		if self.onlineAgentAvailable, let agent = self.agent, let creds = self.getCredentails() {
//			if Session.isLoggedIn {
//                router?.trigger(.chat(agent: agent, user: creds, delegate: self))
//			} else if let credentails = self.getCredentails() {
//				reLogin(credentails: credentails)
//			}
//			// completion(.success(true))
//		} else {
//			router?.trigger(.login(isOnline: self.onlineAgentAvailable))
//			// completion(.success(true))
//		}
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
    
	// Normaly if the credentals are provided
	func reLogin(credentails: Credentials) {
		statusHandler?(.loading)
        Session
            .shared
            .login(using: credentails).on { _ in
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

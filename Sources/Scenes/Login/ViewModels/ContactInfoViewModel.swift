//
//  ContactInfoViewModel.swift
//  Example
//
//  Created by Ali Ammar Hilal on 14.06.2021.
//

import FirebaseAuth
import FirebaseDatabase
import Foundation

final class ContactInfoViewModel {
	weak private var router: Coordinator<MainRoute>?
	private let loginProvider: LoginProvider
	private let agentProvider: AgentProvider
	private let messageProvider: MessagingProvider
	
	let credentials: Credentials?
	let smartPlug: SmartPlug?
	private(set) var isOnline: Bool
    private var isSendingMessage: Bool = false
    
    enum AgentStatus {
        case online
        case offline
    }
    
    var agentStatusHandler: ((AgentStatus) -> Void)?
    
	init(
		router: Coordinator<MainRoute>?,
		loginProvider: LoginProvider,
		credentials: Credentials?,
		smartPlug: SmartPlug? = nil,
		agentProvider: AgentProvider,
		messageProvider: MessagingProvider,
		isOnline: Bool
	) {
		self.router = router
		self.loginProvider = loginProvider
		self.credentials = credentials
		self.smartPlug = smartPlug
		self.agentProvider = agentProvider
		self.messageProvider = messageProvider
		self.isOnline = isOnline
        Session.terminate(forceDeleteCreds: false)
	}
	
	func login(using name: String, email: String) -> Future<Void, Error> {
		let creds = Credentials(name: name, email: email)
        return Session.shared
			.startFlowWith(credentials: creds, smartPlug: self.smartPlug)
			.flatMap(getOnlineAgent)
			.observe(on: .main)
			.map { agent in
				print("Agent =>", agent)
				// guard let agent = agent else { return }
				self.router?.trigger(.chat(agent: agent, user: creds))
			}
	}
	
	func sendOfflineMessage(
        _ message: String,
        customFields: [String: String],
        with credentials: Credentials
    ) -> Future<Void, Error> {
		let message = OfflineMessage(
            name: credentials.name,
            email: credentials.email,
            message: message
        )
        guard !isSendingMessage else { return .init({ _ in }) }
        
        isSendingMessage = true
		return messageProvider
			.sendOfflineMessage(message, customFields: customFields, smartPlugs: self.smartPlug)
			.map { _ in
                self.isSendingMessage = false
				self.router?.trigger(.offlineMessage)
			}
	}

    func listenForAgentStatus() {
        guard let companyID = Storage.settings.object?.companyID else { return }
        let ref = Database.liveChatDB.reference(to: .online(companyID: companyID))
        ref.observe(.value) { snapshot  in
            let value = snapshot.value as? Int ?? 0
            if snapshot.exists() && value > 0 {
                self.isOnline = true
                self.agentStatusHandler?(.online)
            } else {
                self.isOnline = false
                self.agentStatusHandler?(.offline)
            }
        }
    }
    
	private func getOnlineAgent() -> Future<Agent?, Error> {
		let uid = Auth.liveChat.currentUser?.uid ?? ""
		return agentProvider.getOnlineAgentInfo(uid: uid)
	}
	
	func back() {
		router?.trigger(.pop)
	}
}

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
    
    let agent: Agent?
    let credentials: Credentials?
    var statusHandler: ((BaseViewController.State) -> Void)?
    private var isOnlineAgent = false
    
    init(
        router: Coordinator<MainRoute>?,
        feedbackProvider: FeedbackProvider,
        loginProvider: LoginProvider,
        credentials: Credentials?,
        agent: Agent?
    ) {
        self.router = router
        self.feedbackProvider = feedbackProvider
        self.loginProvider = loginProvider
        self.agent = agent
        self.credentials = credentials
        Flow.delay(for: 1.3) {
            Session.terminate(forceDeleteCreds: false)
        }
    }
    
    func prepareTranscript() {
        router?.trigger(.transcript)
    }
    
    func rate(with rating: Rating) -> Future<Void, Error> {
        let sessionID = Session.ID
        return feedbackProvider.rate(session: sessionID, with: rating.rawValue).map { _ in }
    }
    
    func startNewChat() {
        Session.terminate(forceDeleteCreds: false)
        var credentails: Credentials
		var smartPlugs: SmartPlug?
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
            .login(using: credentails, smartPlug: nil)
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
    
    func backToRoot() {
        Session.terminate()
        router?.trigger(.popToRoot)
    }
}

enum Rating: Int {
    case dislike = 0
    case like = 1
}

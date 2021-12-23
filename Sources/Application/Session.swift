//
//  Session.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 19.06.2021.
//

import FirebaseAuth

final class Session {
    
    static let shared = Session()

    static var ID: String {
        Auth.liveChat.currentUser?.uid ?? ""
    }
    
    static var isLoggedIn: Bool {
        Auth.liveChat.currentUser != nil
    }
    
    static var isExpired: Bool {
        guard let expirationDate = Storage.expireDate.object else { return true }
        return Date() > expirationDate
    }
    
    static func checkValidity() {
        if isExpired {
            terminate(forceDeleteCreds: false)
            Storage.token.delete()
        }
    }
    
    static func terminate(forceDeleteCreds: Bool = true) {
        isActive = false
        activeConversation = nil
        Storage.messageStore.deleteAll()
        Storage.activeConversation.delete()
        Storage.token.delete()
        if forceDeleteCreds {
            Storage.credentails.delete()
        }
        try? Storage.isActiveConverationAvailable.save(false)
        try? Storage.mesaagesCache.deleteAll()
        try? Auth.liveChat.signOut()
        NotificationCenter.default.post(.SessionTerminationNotification)
    }
    
    static var isActive = false
    
    static var activeConversation: RecentMessage? {
        get {
            Storage.activeConversation.object
        } set {
            if newValue == nil {
                Storage.activeConversation.delete()
            } else {
                try? Storage.activeConversation.save(newValue)
            }
        }
    }
    
    private let loginProvider: LoginProvider
    
    private init() {
        let factory = ProvidersFactory()
        loginProvider = factory.makeLoginProvider()
    }
    
    static func refreshToken() -> Future<Void, Error> {
        let token = Storage.token.object() ?? ""
        return ProvidersFactory()
            .makeLoginProvider()
            .authenticateSession(with: token)
    }
    
    static var token: String? {
        if isExpired { return nil }
        return Storage.token.object()
    }
    
	func startFlowWith(credentials: Credentials, smartPlug: SmartPlug? = nil) -> Future<Void, Error> {
        let promise = Promise<Void, Error>()
        
        if !Session.isExpired, let token = Session.token {
            loginToFirebase(using: token).on { _ in
                promise.succeed(value: ())
            } failure: { error in
                self.login(using: credentials, smartPlug: smartPlug).on { _ in
                    promise.succeed(value: ())
                } failure: { error in
                    promise.fail(error: error)
                }
            }
            
        } else {
            return login(using: credentials, smartPlug: smartPlug)
        }
        
        return promise.future
    }
    
	func login(using credentials: Credentials, smartPlug: SmartPlug?) -> Future<Void, Error> {
        getLoginToken(for: credentials, smartPlug: smartPlug)
            .flatMap(loginToFirebase(using:))
    }
    
    func loginToFirebase(using token: Token) -> Future<Void, Error> {
        loginProvider.authenticateSession(with: token)
    }
    
	private func getLoginToken(for credentials: Credentials, smartPlug: SmartPlug?) -> Future<Token, Error> {
		loginProvider.login(using: credentials, smartPlugs: smartPlug)
            .map { $0.token }
			.map { token in
				Logger.log(event: .info, "HELLO \(token)")
				return self.saveLoginToken(token)
			}
    }
    
    private func saveLoginToken(_ token: Token) -> Token {
        let expirationDate = Calendar.current.date(byAdding: .hour, value: 24, to: Date())
        try? Storage.expireDate.save(expirationDate)
        try? Storage.token.save(token)
        return token
    }
}

extension Notification {
    static let SessionTerminationNotification = Notification(name: .init(rawValue: "LiveChatSessionTerminationNotification"))
}

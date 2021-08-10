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
            terminate()
            Storage.token.delete()
           // Storage.credentails.delete()
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
    
    func startFlowWith(credentials: Credentials) -> Future<Void, Error> {
        let promise = Promise<Void, Error>()
        
        if !Session.isExpired, let token = Session.token {
            loginToFirebase(using: token).on { _ in
                promise.succeed(value: ())
            } failure: { error in
                self.login(using: credentials).on { _ in
                    promise.succeed(value: ())
                } failure: { error in
                    promise.fail(error: error)
                }
            }
            
        } else {
            return login(using: credentials)
        }
        
        return promise.future
    }
    
    func startFlowWithoutCredentials() -> Future<Void, Error> {
        let promise = Promise<Void, Error>()
        
        if let token = Session.token {
            loginToFirebase(using: token)
                .on { _ in
                    promise.succeed(value: ())
                } failure: { error in
                    if let cred = Storage.credentails.object {
                         self.login(using: cred).on { _ in
                            promise.succeed(value: ())
                         }
                    } else {
                        promise.fail(error: AnyError(message: "Failed to authenticate"))
                        // return promise.future
                    }
                }
            //                .ifFailsFlatMap { error in
            //                    if let cred = Storage.credentails.object {
            //                        return self.login(using: cred)
            //                    } else {
            //                        promise.fail(error: AnyError(message: "failed to autuntiate"))
            //                        return promise.future
            //                    }
            //                }
        } else {
            promise.succeed(value: ())
          //  return promise.future
        }
        return promise.future
    }
    
    func login(using credentials: Credentials) -> Future<Void, Error> {
        getLoginToken(for: credentials)
            .flatMap(loginToFirebase(using:))
    }
    
    func loginToFirebase(using token: Token) -> Future<Void, Error> {
        loginProvider.authenticateSession(with: token)
    }
    
    private func getLoginToken(for credentials: Credentials) -> Future<Token, Error> {
        loginProvider.login(using: credentials)
            .map { $0.token }
            .map(saveLoginToken(_:))
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

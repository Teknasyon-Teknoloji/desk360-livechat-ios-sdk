//
//  LiveChat.swift
//  Example
//
//  Created by Ali Ammar Hilal on 14.04.2021.
//

import CoreText
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import UIKit

public final class Desk360LiveChat {
    static public let shared = Desk360LiveChat()
    
    private var appCoordinator: AppCoordinator?
    var defaultStatusBarColor: UIColor?
    
    /// Start the live chat view instance and presents it on the given view controller.
    /// - Parameters:
    ///   - appKey: The cuurent app key.
    ///   - credentials: The credentials pf the current logged in user of the app or nil if not available.
    ///   - viewController: The view controll to present the live chat instance on.
    public func start(
        appKey: String,
        host: String,
        language: String? = nil,
        using credentials: Credentials?,
        on viewController: UIViewController) {
        if appKey.isEmpty || host.isEmpty {
            NSException(
                name: .init("liveChatInvalidArguments"),
                reason: "API key or host name can not be empty"
            )
            .raise()
        }
        
        self.defaultStatusBarColor = UIApplication.shared.statusBarUIView?.backgroundColor
        
        appCoordinator = AppCoordinator(
            credentials: credentials,
            factory: ProvidersFactory(),
            presenter: viewController
        )
        
        try? Storage.appKey.save(appKey)
        try? Storage.langaugeCode.save(language)
        try? Storage.host.save(host)
        try? Storage.credentails.save(credentials)
        
        appCoordinator?.trigger(.bootstrap)
    }
    
    /// An array of view controllers to be excluded from being managed by `IQKeyboardManager` if it is used by the
    /// embedding application.
    public var viewControllersToBeExcludedFromIQKeyboardManager: [AnyObject.Type] {
        [
            ChatViewController.self
        ]
    }
}

extension FirebaseApp {
    
	static var liveChatAppName = "DESK360-live-chat-sdk-app"
    static var liveChatApp: FirebaseApp? {
		guard let app = FirebaseApp.app(name: FirebaseApp.liveChatAppName) else { return nil }
        return app
    }
}

extension Database {
    static var liveChatDB: Database {
        guard let app = FirebaseApp.liveChatApp else { fatalError() }
        let db = Database.database(app: app)
        return db
    }
}

extension Auth {
    static var liveChat: Auth {
        guard let app = FirebaseApp.liveChatApp else { fatalError() }
        return Auth.auth(app: app)
    }
}

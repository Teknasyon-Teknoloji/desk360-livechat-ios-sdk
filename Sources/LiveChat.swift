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

public struct LiveChatProperties {
    public let appKey: String
    public let host: String
    public let deviceID: String
    public let language: String?
    public let loginCredentials: Credentials?
    
    public init(
        appKey: String,
        host: String,
        deviceID: String,
        language: String? = nil,
        loginCredentials: Credentials? = nil
    ) {
        self.appKey = appKey
        self.host = host
        self.deviceID = deviceID
        self.language = language
        self.loginCredentials = loginCredentials
    }
}

public final class Desk360LiveChat {
    static public let shared = Desk360LiveChat()
    
    private var appCoordinator: AppCoordinator?
    
    var pushToken: String {
        get { Storage.pushToken.object ?? "" }
        set { try? Storage.pushToken.save(newValue) }
    }
    
    var deviceID: String?
    var defaultStatusBarColor: UIColor?
    
    /// An array of view controllers to be excluded from being managed by `IQKeyboardManager` if it is used by the
    /// embedding application.
    public var viewControllersToBeExcludedFromIQKeyboardManager: [AnyObject.Type] {
        [
            ChatViewController.self
        ]
    }
    
    private init() {
        listenForAppLifeCycleEvents()
    }
    
    /// Start the live chat view instance and presents it on the given view controller.
    /// - Parameters:
    ///   - properites: The credentials pf the current logged in user of the app or nil if not available.
    ///   - viewController: The view controll to present the live chat instance on.
    public func start(using properites: LiveChatProperties, on viewController: UIViewController) {
        
        if properites.appKey.isEmpty || properites.host.isEmpty {
            NSException(
                name: .init("liveChatInvalidArguments"),
                reason: "API key or host name can not be empty"
            )
            .raise()
        }
        
        self.defaultStatusBarColor = UIApplication.shared.statusBarUIView?.backgroundColor
        self.deviceID = properites.deviceID
        
        appCoordinator = AppCoordinator(
            credentials: properites.loginCredentials,
            factory: ProvidersFactory(),
            presenter: viewController
        )
        
        try? Storage.appKey.save(properites.appKey)
        try? Storage.langaugeCode.save(properites.language)
        try? Storage.host.save(properites.host)
        if let creds = properites.loginCredentials {
            try? Storage.credentails.save(creds)
        } else {
            Storage.credentails.delete()
        }
       
        
        appCoordinator?.trigger(.bootstrap)
    }
    
    public func setPushToken(deviceToken: Data? = nil) {
        guard let token = deviceToken else { return }
        let tokenString = token.reduce("", {$0 + String(format: "%02X", $1)})
        pushToken = tokenString
        Logger.Log("Desk360LiveChat Push Token \(tokenString)")
    }
    
    public func checkForNotificationLaunch(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard let remoteNotif = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any] else { return }
        guard let data = remoteNotif["data"] as? [String: Any] else { return }
        guard let id = userInfoHandle(data) else { return }
        presentFromDeepLink(sessionID: id)
    }
    
    public func checkNotificationInfo(userInfo: [AnyHashable: Any]?) {
        guard let data = userInfo?["data"] as? [String: AnyObject] else { return }
        guard let id = userInfoHandle(data) else { return }
        presentFromDeepLink(sessionID: id)
    }
    

    private func userInfoHandle(_ data: [String: Any]) -> String? {
        guard let hermes = data["hermes"] as? [String: AnyObject] else { return nil }
        guard let detail = hermes["target_detail"] as? [String: AnyObject] else { return nil }
        guard let categoryId = detail["target_category"] as? String else { return nil }
        guard categoryId == "Desk360Deeplink" else { return nil }
        guard let id = detail["session_id"] as? String else { return nil }
        return id
    }
    
    private func presentFromDeepLink(sessionID: String) {
        guard let config = Storage.settings.object?.firebaseConfig else { return }
        FirebaseApp.initIfNeeded(using: config)
        
        if let topViewController = UIApplication.topViewController() {
            appCoordinator = .init(credentials: nil, factory: ProvidersFactory(), presenter: topViewController)
        }
        guard let creds = Storage.credentails.object else { return }
        appCoordinator?.deepLink([.bootstrap, .intro, .chat(agent: nil, user: creds, delegate: nil)])
    }
    
    private func listenForAppLifeCycleEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeNotificationStatus), name: UIApplication.willTerminateNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeNotificationStatus), name: UIApplication.willResignActiveNotification, object: nil)
    }

    @objc private func changeNotificationStatus() {
        guard let config = Storage.settings.object?.firebaseConfig else { return }
        FirebaseApp.initIfNeeded(using: config)
        
        ProvidersFactory().makeMessagingProvider().shouldRecieveNotifications(true)
    }
}

extension FirebaseApp {
    static var liveChatAppName = "DESK360-live-chat-sdk-app"
    static var liveChatApp: FirebaseApp? {
        guard let app = FirebaseApp.app(name: FirebaseApp.liveChatAppName) else { return nil }
        return app
    }
    
    static func initIfNeeded(using config: FirebaseConfig, validateSession: Bool = true) {
        let appID = config.appID.replacingOccurrences(of: "web", with: "ios")
        let gcmID = config.appID.components(separatedBy: ":")[1]
        
        let options = FirebaseOptions(
            googleAppID: appID,
            gcmSenderID: gcmID
        )
        
        options.apiKey = config.apiKey
        options.databaseURL = config.databaseURL
        options.projectID = config.projectID
        if FirebaseApp.liveChatApp == nil {
            FirebaseApp.configure(name: FirebaseApp.liveChatAppName, options: options)
        }
        
        if validateSession {
            Session.checkValidity()
        }
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

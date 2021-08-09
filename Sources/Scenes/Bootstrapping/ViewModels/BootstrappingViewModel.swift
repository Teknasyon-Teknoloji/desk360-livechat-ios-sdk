//
//  BootstrappingViewModel.swift
//  Example
//
//  Created by Ali Ammar Hilal on 27.04.2021.
//

import FirebaseCore
import Foundation
import UIKit
import FirebaseAuth

class BootstrappingViewModel {
    weak var router: Coordinator<MainRoute>?
    private let settingsProvider: SettingsProvider
    private let credentials: Credentials?
    private let loginProvider: LoginProvider
    private let agentProvider: AgentProvider
    
    init(
        router: Coordinator<MainRoute>,
        settingsProvider: SettingsProvider,
        credentials: Credentials?,
        loginProvider: LoginProvider,
        agentProvider: AgentProvider
    ) {
        self.router 			= router
        self.settingsProvider   = settingsProvider
        self.credentials 		= credentials
        self.loginProvider  	= loginProvider
        self.agentProvider      = agentProvider
    }
    
    func bootstrap() -> Future<Void, Error> {
        fetchSettings()
            .flatMap(prepare)
    }
    
    func prepare() -> Future<Void, Error> {
        if let token = Session.token {
            Session.shared.loginToFirebase(using: token).on { _ in
            } failure: { error in
                Logger.logError(error)
                Session.terminate()
            }
        }
        
        self.router?.trigger(.intro)
        return .init(result: .success(()))
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
    
    func cacheActiveConverdation(_ conversation: RecentMessage?) {
        Session.activeConversation = conversation
    }
    
    private func fetchSettings() -> Future<Void, Error> {
        let hasValidSettingsSaved = Storage.settings.hasObject
        if hasValidSettingsSaved, let settings = Storage.settings.object {
            initFirebase(using: settings.firebaseConfig)
            router?.trigger(.intro)
            return getSettings()
        }
        return getSettings()
    }
    
    private func getSettings() -> Future<Void, Error> {
        var languageCode = Environmet.current.languageCode.lowercased()
        if ["pt", "nb"].contains(languageCode) {
            languageCode = Locale.preferredLanguages.first?.lowercased() ?? "en"
        }
        
        return settingsProvider
            .getSettings(language: languageCode)
            .map { settings -> Void in
                try? Storage.settings.save(settings)
                self.initFirebase(using: settings.firebaseConfig)
            }
    }
    
    private func initFirebase(using config: FirebaseConfig) {
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
            FirebaseApp.configure(name: appName, options: options)
        }
        
        Session.checkValidity()
    }
}

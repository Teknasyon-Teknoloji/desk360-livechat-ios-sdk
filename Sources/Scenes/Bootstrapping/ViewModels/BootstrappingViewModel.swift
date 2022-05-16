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
        Auth.liveChat.currentUser?.getIDTokenForcingRefresh(true, completion: nil)
		if !Storage.isFirst.hasObject {
			router?.trigger(.intro)
			try? Storage.isFirst.save(true)
		}
        return .init(result: .success(()))
    }
    
    private func fetchSettings() -> Future<Void, Error> {
        let hasValidSettingsSaved = Storage.settings.hasObject
        if hasValidSettingsSaved, let settings = Storage.settings.object {
            initFirebase(using: settings.firebaseConfig)
            if settings.isActiveCannedResponse, let response = settings.cannedResponse {
                CannedResponseAttributeCollector.shared.collectData(for: response)
            }
            router?.trigger(.intro)
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
				
				if settings.isActiveCannedResponse {
					guard let cannedResponse = settings.cannedResponse else { return }
					DispatchQueue.main.async {
						CannedResponseAttributeCollector.shared.collectData(for: cannedResponse)
					}
				}
				
                FirebaseApp.initIfNeeded(using: settings.firebaseConfig)
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
            FirebaseApp.configure(name: FirebaseApp.liveChatAppName, options: options)
        }
        
        Session.checkValidity()
    }
}

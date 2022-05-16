//
//  Storage.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 22.04.2021.
//

import Foundation
import PersistenceKit

// swiftlint:disable force_unwrapping

/// Application data stores.
struct Storage {
	private init() {}
    
	static let isFirst = SingleUserDefaultsStore<Bool>(uniqueIdentifier: .isFirst)!
	
    static let settings = SingleUserDefaultsStore<Settings>(uniqueIdentifier: .settings)!
    
    static let appKey = SingleKeychainStore<String>(uniqueIdentifier: .appKey)
    
    static let token = SingleKeychainStore<String>(uniqueIdentifier: .token)
    
    static let credentails = SingleUserDefaultsStore<Credentials>(uniqueIdentifier: .credentails)!
	
	static let smartPlug = SingleUserDefaultsStore<SmartPlug>(uniqueIdentifier: .smartPlugs)!
	
    static let messageStore = FilesStore<ChatMediaItem>(uniqueIdentifier: .attachments)
    
    static let expireDate = SingleUserDefaultsStore<Date>(uniqueIdentifier: .tokenExpiryDate)!
    
    static let activeConversation = SingleUserDefaultsStore<RecentMessage>(uniqueIdentifier: .activeConversation)!
    
    static let isActiveConverationAvailable = SingleUserDefaultsStore<Bool>(uniqueIdentifier: .isActiveConverationAvailable)!
    
    static let mesaagesCache = UserDefaultsStore<Message>(uniqueIdentifier: .messageStore)!
    
    static let host = SingleUserDefaultsStore<String>(uniqueIdentifier: .host)!

    static let langaugeCode = SingleUserDefaultsStore<String>(uniqueIdentifier: .langaugeCode)!
    
    static let pushToken = SingleUserDefaultsStore<String>(uniqueIdentifier: .pushToken)!
    
    static func clear() {
        settings.delete()
        appKey.delete()
        credentails.delete()
        messageStore.deleteAll()
        expireDate.delete()
        activeConversation.delete()
        isActiveConverationAvailable.delete()
        mesaagesCache.deleteAll()
        host.delete()
        
        token.delete()
    }
}
// swiftlint:enable force_unwrapping

@propertyWrapper
private struct StorageKey {
    var wrappedValue: String

    init(wrappedValue: String) {
        let fullKey = "desk360_live_chat_" + wrappedValue
        self.wrappedValue = fullKey
    }
}

private extension String {
	
	@StorageKey
	static private(set) var isFirst = "is_first"
	
    @StorageKey
    static private(set) var token = "token"
    
    @StorageKey
    static private(set) var appKey = "app_key"
    
    @StorageKey
    static private(set) var settings = "settings"
    
    @StorageKey
    static private(set) var credentails = "credentails"
	
	@StorageKey
	static private(set) var smartPlugs = "smart_plugs"
    
    @StorageKey
    static private(set) var messageStore = "message_store"
    
    @StorageKey
    static private(set) var attachments = "attachments"
    
    @StorageKey
    static private(set) var tokenExpiryDate = "token_expired_date"
    
    @StorageKey
    static private(set) var activeConversation = "active_conversation"
    
    @StorageKey
    static private(set) var isActiveConverationAvailable = "is_active_converation_available"
    
    @StorageKey
    static private(set) var mesaagesCache = "mesaages_cache"
    
    @StorageKey
    static private(set) var host = "host"
    
    @StorageKey
    static private(set) var langaugeCode = "langauge_code"
    
    @StorageKey
    static private(set) var pushToken = "push_token"
}

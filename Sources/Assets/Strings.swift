//
//  Strings.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 22.04.2021.
//

import Foundation

var config: Config? {
	Storage.settings.object?.config
}

struct Strings {
	
	private static let lang = Storage.settings.object?.language
	private static let chat = Storage.settings.object?.config.chat
	private static let feedback = Storage.settings.object?.config.feedback
	
	static var loginWelcomeTitle: String {
		config?.general.headerTitle ?? "Hi there"
	}
	
	static var loginWelcomeSubTitle: String {
		config?.general.headerSubTitle ?? "Hi there"
	}
	
	static var startChatContainerHeader: String {
		config?.general.sectionHeaderTitle ?? "Start a new chat"
	}
	
	static var startChatContainerSubTitle: String {
		config?.general.sectionHeaderText ?? "We usually reply within a few minutes."
	}
	
	static var startChatSendMessageButtonText: String {
		config?.general.sendButtonText ?? "Send Message"
	}
	
	static var companyName: String {
		(config?.general.brandName ?? Storage.settings.object?.applicationName) ?? "Company Name"
	}
	
	static var faqContainerTitle: String {
		Storage.settings.object?.language.resolve(keyPath: "faq_search_title", orDefault: "") ?? ""
	}
	
	static var faqSearchPlaceholder: String {
		Storage.settings.object?.language.resolve(keyPath: "faq_search_placeholder", orDefault: "") ?? ""
	}
	
	static var faqLoadMore: String {
		Storage.settings.object?.language.resolve(keyPath: "faq_search_placeholder", orDefault: "") ?? ""
	}
	
	static var faqGoBack: String {
		Storage.settings.object?.language.resolve(keyPath: "faq_back", orDefault: "") ?? ""
	}
	
	static var messageFeedback: String {
		lang?.resolve(keyPath: "feedback_message", orDefault: "Thank you. We will contact you as soon as possible.") ?? ""
	}
	
	static var `break`: String {
		lang?.resolve(keyPath: "break", orDefault: "") ?? ""
	}

	static var emoji_frequently_used: String {
		lang?.resolve(keyPath: "emoji_frequently_used", orDefault: "") ?? ""
	}
	
	static var emoji_nature: String {
		lang?.resolve(keyPath: "emoji_nature", orDefault: "") ?? ""
	}
	
	static var emoji_objects: String {
		lang?.resolve(keyPath: "emoji_objects", orDefault: "") ?? ""
	}
	
	static var emoji_places: String {
		lang?.resolve(keyPath: "emoji_places", orDefault: "") ?? ""
	}
	
	static var emoji_search: String {
		lang?.resolve(keyPath: "emoji_search", orDefault: "") ?? ""
	}
	
	static var emoji_symbols: String {
		lang?.resolve(keyPath: "emoji_symbols", orDefault: "") ?? ""
	}
	
	static var faq_back: String {
		lang?.resolve(keyPath: "faq_back", orDefault: "") ?? ""
	}
	
	static var feedback_button: String {
		lang?.resolve(keyPath: "feedback_button", orDefault: "") ?? ""
	}
	
	static var feedback_success_title: String {
		lang?.resolve(keyPath: "feedback_success_title", orDefault: "") ?? ""
	}
	
	static var feedback_title: String {
		lang?.resolve(keyPath: "feedback_title", orDefault: "") ?? ""
	}
	
	static var header_menu_endchat: String {
		lang?.resolve(keyPath: "header_menu_endchat", orDefault: "") ?? ""
	}
	
	static var header_menu_transcript: String {
		lang?.resolve(keyPath: "header_menu_transcript", orDefault: "") ?? ""
	}
	
	static var invisible: String {
		lang?.resolve(keyPath: "invisible", orDefault: "") ?? ""
	}
	
	static var login_description: String {
		lang?.resolve(keyPath: "login_description", orDefault: "") ?? ""
	}
	
	static var login_input_email: String {
		lang?.resolve(keyPath: "login_input_email", orDefault: "") ?? ""
	}
	
	static var login_input_name: String {
		lang?.resolve(keyPath: "login_input_name", orDefault: "") ?? ""
	}
	
	static var login_title: String {
		lang?.resolve(keyPath: "login_title", orDefault: "") ?? ""
	}
	
	static var message_failed_to_send: String {
		lang?.resolve(keyPath: "message_failed_to_send", orDefault: "") ?? ""
	}
	
	static var message_sent_title: String {
		lang?.resolve(keyPath: "message_sent_title", orDefault: "") ?? ""
	}
	
	static var offline: String {
		lang?.resolve(keyPath: "offline", orDefault: "") ?? ""
	}
	
	static var offline_button: String {
		lang?.resolve(keyPath: "offline_button", orDefault: "") ?? ""
	}
	
	static var offline_description: String {
		lang?.resolve(keyPath: "offline_description", orDefault: "") ?? ""
	}
	
	static var offline_input_email: String {
		lang?.resolve(keyPath: "offline_input_email", orDefault: "") ?? ""
	}
	
	static var offline_input_message: String {
		lang?.resolve(keyPath: "offline_input_message", orDefault: "") ?? ""
	}

	static var offline_input_name: String {
		lang?.resolve(keyPath: "offline_input_name", orDefault: "") ?? ""
	}
	
	static var offline_input_name_surname: String {
		lang?.resolve(keyPath: "offline_input_name_surname", orDefault: "") ?? ""
	}
	
	static var offline_input_your_message: String {
		lang?.resolve(keyPath: "offline_input_your_message", orDefault: "") ?? ""
	}
	
	static var offline_message_button: String {
		lang?.resolve(keyPath: "offline_message_button", orDefault: "") ?? ""
	}
	
	static var offline_message_error_description: String {
		lang?.resolve(keyPath: "offline_message_error_description", orDefault: "") ?? ""
	}
	
	static var offline_message_error_title: String {
		lang?.resolve(keyPath: "offline_message_error_title", orDefault: "") ?? ""
	}
	
    static var title: String {
        lang?.resolve(keyPath: "title", orDefault: "") ?? ""
    }
    
	static var offline_message_success_description: String {
		lang?.resolve(keyPath: "offline_message_success_description", orDefault: "") ?? ""
	}
	
	static var offline_message_success_title: String {
		lang?.resolve(keyPath: "offline_message_success_title", orDefault: "") ?? ""
	}
	
	static var offline_title: String {
		lang?.resolve(keyPath: "offline_title", orDefault: "") ?? ""
	}
	
	static var online: String {
		lang?.resolve(keyPath: "online", orDefault: "") ?? ""
	}
	
	static var online_drop_files: String {
		lang?.resolve(keyPath: "online_drop_files", orDefault: "") ?? ""
	}
	
	static var online_end_chat: String {
		lang?.resolve(keyPath: "online_end_chat", orDefault: "") ?? ""
	}
	
	static var online_message: String {
		lang?.resolve(keyPath: "online_message", orDefault: "") ?? ""
	}
	
	static var online_search: String {
		lang?.resolve(keyPath: "online_search", orDefault: "") ?? ""
	}
	
	static var read_more: String {
		lang?.resolve(keyPath: "read_more", orDefault: "") ?? ""
	}
	
	static var required_message: String {
		lang?.resolve(keyPath: "required_message", orDefault: "") ?? ""
	}
	
	static var send_message: String {
		lang?.resolve(keyPath: "send_message", orDefault: "") ?? ""
	}
	
	static var transcript_button: String {
		lang?.resolve(keyPath: "transcript_button", orDefault: "") ?? ""
	}
	
	static var transcript_close_the_chat: String {
		lang?.resolve(keyPath: "transcript_close_the_chat", orDefault: "") ?? ""
	}
	
	static var transcript_description: String {
		lang?.resolve(keyPath: "transcript_description", orDefault: "") ?? ""
	}
	
	static var transcript_title: String {
		lang?.resolve(keyPath: "transcript_title", orDefault: "") ?? ""
	}
	
	static var waiting: String {
		lang?.resolve(keyPath: "waiting", orDefault: "") ?? ""
	}
	
	static var write_a_message: String {
		lang?.resolve(keyPath: "write_a_message", orDefault: "") ?? ""
	}
	
	// MARK: - CHAT
	static var button_text: String {
		chat?.buttonText ?? ""
	}
	
	static var welcome_message: String {
		chat?.welcomeMessage ?? ""
	}
	
	static var feedback_message: String {
		chat?.feedbackMessage ?? ""
	}
	
	// MARK: - Feedback
	static var feedBackHeaderTitle: String {
		feedback?.headerTitle ?? ""
	}
	
	static var feedbackHeaderText: String {
		feedback?.headerText ?? ""
	}
	
	static var feedbackBottomText: String {
		feedback?.bottomText ?? ""
	}
	
	static var feedbackBottomLink: String {
		feedback?.bottomLink ?? ""
	}
    
    static var online_typing: String {
        lang?.resolve(keyPath: "online_typing", orDefault: "") ?? ""
    }
    
    static var sdk_an_error_has_occurred: String {
        lang?.resolve(keyPath: "sdk_an_error_has_occurred", orDefault: "") ?? ""
    }
    
    static var sdk_check_your_connection: String {
        lang?.resolve(keyPath: "sdk_check_your_connection", orDefault: "") ?? ""
    }
    
    static var sdk_choose_document: String {
        lang?.resolve(keyPath: "sdk_choose_document", orDefault: "") ?? ""
    }
    
    static var sdk_document: String {
        lang?.resolve(keyPath: "sdk_document", orDefault: "") ?? ""
    }
    
    static var sdk_downloading: String {
        lang?.resolve(keyPath: "sdk_downloading", orDefault: "") ?? ""
    }
    
    static var sdk_error: String {
        lang?.resolve(keyPath: "sdk_error", orDefault: "") ?? ""
    }
    
    static var sdk_failed_to_send_message: String {
        lang?.resolve(keyPath: "sdk_failed_to_send_message", orDefault: "") ?? ""
    }
    
    static var sdk_file_cannot_be_opened: String {
        lang?.resolve(keyPath: "sdk_file_cannot_be_opened", orDefault: "") ?? ""
    }
    
    static var sdk_file_limit: String {
        lang?.resolve(keyPath: "sdk_file_limit", orDefault: "") ?? ""
    }
    
    static var sdk_image: String {
        lang?.resolve(keyPath: "sdk_image", orDefault: "") ?? ""
    }
    
    static var sdk_information: String {
        lang?.resolve(keyPath: "sdk_information", orDefault: "") ?? ""
    }
    
    static var sdk_no_connection: String {
        lang?.resolve(keyPath: "sdk_no_connection", orDefault: "") ?? ""
    }
    
    static var sdk_ok: String {
        lang?.resolve(keyPath: "sdk_ok", orDefault: "") ?? ""
    }
    
    static var sdk_photo: String {
        lang?.resolve(keyPath: "sdk_photo", orDefault: "") ?? ""
    }
    
    static var sdk_session_is_ended: String {
        lang?.resolve(keyPath: "sdk_no_connection", orDefault: "") ?? ""
    }
    
    static var sdk_success: String {
        lang?.resolve(keyPath: "sdk_success", orDefault: "") ?? ""
    }
    
    static var sdk_uploading: String {
        lang?.resolve(keyPath: "sdk_uploading", orDefault: "") ?? ""
    }
    
    static var sdk_video: String {
        lang?.resolve(keyPath: "sdk_video", orDefault: "") ?? ""
    }
    
    static var sdk_warning: String {
        lang?.resolve(keyPath: "sdk_warning", orDefault: "") ?? ""
    }
	
	// MARK: - Canned Response Strings
	static var canned_response_feedback_button_bad: String {
		lang?.resolve(keyPath: "canned_response_feedback_button_bad", orDefault: "") ?? ""
	}
	
	static var canned_response_feedback_button_good: String {
		lang?.resolve(keyPath: "canned_response_feedback_button_good", orDefault: "") ?? ""
	}
	
	static var canned_response_feedback_description: String {
		lang?.resolve(keyPath: "canned_response_feedback_description", orDefault: "") ?? ""
	}
	
	static var canned_response_feedback_success_title: String {
		lang?.resolve(keyPath: "canned_response_feedback_success_title", orDefault: "") ?? ""
	}
	
	static var canned_response_feedback_title: String {
		lang?.resolve(keyPath: "canned_response_feedback_title", orDefault: "") ?? ""
	}
	
	static var canned_response_list_menu_title: String {
		lang?.resolve(keyPath: "canned_response_list_menu_title", orDefault: "") ?? ""
	}
	
	static var canned_response_list_title: String {
		lang?.resolve(keyPath: "canned_response_list_title", orDefault: "") ?? ""
	}
	
	static var confirmation_end_conversation_button_no: String {
		lang?.resolve(keyPath: "confirmation_end_conversation_button_no", orDefault: "") ?? ""
	}
	
	static var confirmation_end_conversation_button_yes: String {
		lang?.resolve(keyPath: "confirmation_end_conversation_button_yes", orDefault: "") ?? ""
	}
	
	static var confirmation_end_conversation_title: String {
		lang?.resolve(keyPath: "confirmation_end_conversation_title", orDefault: "") ?? ""
	}
	
}

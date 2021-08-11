// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - DataClass
struct Settings: Codable {
	var companyID: Int
	let language: [String: String]
	let triggers: [JSONAny]?
	let config: Config
	let chatbot: Bool
	let chatbotSettings: ChatbotSettings?
	let applicationName: String?
	let applicationLogo: String?
    let firebaseConfig: FirebaseConfig
    
	enum CodingKeys: String, CodingKey {
		case companyID = "company_id"
		case language, triggers, config, chatbot
		case chatbotSettings = "chatbot_settings"
		case applicationName = "application_name"
		case applicationLogo = "application_logo"
        case firebaseConfig = "firebase_config"
	}
}

// MARK: - FirebaseConfig
struct FirebaseConfig: Codable {
    let apiKey, appID, projectID: String
    let databaseURL: String
    let messagingSenderID: String

    enum CodingKeys: String, CodingKey {
        case apiKey = "api_key"
        case appID = "app_id"
        case projectID = "project_id"
        case databaseURL = "database_url"
        case messagingSenderID = "messaging_sender_id"
    }
}

// MARK: - ChatbotSettings
struct ChatbotSettings: Codable {
	let languages: [String]?
	let defaultLanguage: String?

	enum CodingKeys: String, CodingKey {
		case languages
		case defaultLanguage = "default_language"
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.languages = try container.decodeIfPresent([String].self, forKey: .languages) ?? []
		self.defaultLanguage = try container.decodeIfPresent(String.self, forKey: .defaultLanguage) ?? ""
	}
}

// MARK: - Config
struct Config: Codable {
	let general: General
	let offline: Offline
	let online: Online
	let chat: Chat
	let feedback: Feedback
}

// MARK: - Chat
struct Chat: Codable {
	let addFileStatus, typingStatus: Bool
	let writeMessageTextColor, writeMessageIconColor, placeholderColor, buttonText: String
	let welcomeMessage, feedbackMessage, messageBackgroundColor, messageTextColor: String

	enum CodingKeys: String, CodingKey {
		case addFileStatus = "add_file_status"
		case typingStatus = "typing_status"
		case writeMessageTextColor = "write_message_text_color"
		case writeMessageIconColor = "write_message_icon_color"
		case placeholderColor = "placeholder_color"
		case buttonText = "button_text"
		case welcomeMessage = "welcome_message"
		case feedbackMessage = "feedback_message"
		case messageBackgroundColor = "message_background_color"
		case messageTextColor = "message_text_color"
	}
}

// MARK: - Feedback
struct Feedback: Codable {
	let headerTitle, headerText, bottomText, bottomLink: String
	let bottomLinkColor, iconUpColor, iconDownColor: String

	enum CodingKeys: String, CodingKey {
		case headerTitle = "header_title"
		case headerText = "header_text"
		case bottomText = "bottom_text"
		case bottomLink = "bottom_link"
		case bottomLinkColor = "bottom_link_color"
		case iconUpColor = "icon_up_color"
		case iconDownColor = "icon_down_color"
	}
}

// MARK: - General
struct General: Codable {
	let brandLogo, brandName: String?
	let widgetIcon: String?
	let agentPictureStatus: Bool?
	let headerTitle, headerTitleColor, headerSubTitle, headerSubTitleColor: String
	let backgroundColor, backgroundHeaderColor, backgroundMainColor, sendButtonText: String
	let sendButtonTextColor, sendButtonIconColor, sendButtonBackgroundColor, sectionHeaderTitle: String
    let sectionHeaderTitleColor, sectionHeaderText, sectionHeaderTextColor: String
    let linkTextColor: String?

	enum CodingKeys: String, CodingKey {
		case brandLogo = "brand_logo"
		case brandName = "brand_name"
		case widgetIcon = "widget_icon"
		case agentPictureStatus = "agent_picture_status"
		case headerTitle = "header_title"
		case headerTitleColor = "header_title_color"
		case headerSubTitle = "header_sub_title"
		case headerSubTitleColor = "header_sub_title_color"
		case backgroundColor = "background_color"
		case backgroundHeaderColor = "background_header_color"
		case backgroundMainColor = "background_main_color"
		case sendButtonText = "send_button_text"
		case sendButtonTextColor = "send_button_text_color"
		case sendButtonIconColor = "send_button_icon_color"
		case sendButtonBackgroundColor = "send_button_background_color"
		case sectionHeaderTitle = "section_header_title"
		case sectionHeaderTitleColor = "section_header_title_color"
		case sectionHeaderText = "section_header_text"
		case sectionHeaderTextColor = "section_header_text_color"
		case linkTextColor = "link_text_color"
	}
}

// MARK: - Offline
struct Offline: Codable {
	let headerText: String
	let triggersStatus: Bool
	let customFields: [JSONAny]

	enum CodingKeys: String, CodingKey {
		case headerText = "header_text"
		case triggersStatus = "triggers_status"
		case customFields = "custom_fields"
	}
}

// MARK: - Online
struct Online: Codable {
	let headerText: String
	let triggersStatus: Bool

	enum CodingKeys: String, CodingKey {
		case headerText = "header_text"
		case triggersStatus = "triggers_status"
	}
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

	public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
		return true
	}

	public var hashValue: Int {
		return 0
	}

	public func hash(into hasher: inout Hasher) {
		// No-op
	}

	public init() {}

	public required init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if !container.decodeNil() {
			throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encodeNil()
	}
}

class JSONCodingKey: CodingKey {
	let key: String

	required init?(intValue: Int) {
		return nil
	}

	required init?(stringValue: String) {
		key = stringValue
	}

	var intValue: Int? {
		return nil
	}

	var stringValue: String {
		return key
	}
}

class JSONAny: Codable {

	let value: Any

	static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
		let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
		return DecodingError.typeMismatch(JSONAny.self, context)
	}

	static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
		let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
		return EncodingError.invalidValue(value, context)
	}

	static func decode(from container: SingleValueDecodingContainer) throws -> Any {
		if let value = try? container.decode(Bool.self) {
			return value
		}
		if let value = try? container.decode(Int64.self) {
			return value
		}
		if let value = try? container.decode(Double.self) {
			return value
		}
		if let value = try? container.decode(String.self) {
			return value
		}
		if container.decodeNil() {
			return JSONNull()
		}
		throw decodingError(forCodingPath: container.codingPath)
	}

	static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
		if let value = try? container.decode(Bool.self) {
			return value
		}
		if let value = try? container.decode(Int64.self) {
			return value
		}
		if let value = try? container.decode(Double.self) {
			return value
		}
		if let value = try? container.decode(String.self) {
			return value
		}
		if let value = try? container.decodeNil() {
			if value {
				return JSONNull()
			}
		}
		if var container = try? container.nestedUnkeyedContainer() {
			return try decodeArray(from: &container)
		}
		if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
			return try decodeDictionary(from: &container)
		}
		throw decodingError(forCodingPath: container.codingPath)
	}

	static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
		if let value = try? container.decode(Bool.self, forKey: key) {
			return value
		}
		if let value = try? container.decode(Int64.self, forKey: key) {
			return value
		}
		if let value = try? container.decode(Double.self, forKey: key) {
			return value
		}
		if let value = try? container.decode(String.self, forKey: key) {
			return value
		}
		if let value = try? container.decodeNil(forKey: key) {
			if value {
				return JSONNull()
			}
		}
		if var container = try? container.nestedUnkeyedContainer(forKey: key) {
			return try decodeArray(from: &container)
		}
		if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
			return try decodeDictionary(from: &container)
		}
		throw decodingError(forCodingPath: container.codingPath)
	}

	static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
		var arr: [Any] = []
		while !container.isAtEnd {
			let value = try decode(from: &container)
			arr.append(value)
		}
		return arr
	}

	static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
		var dict = [String: Any]()
		for key in container.allKeys {
			let value = try decode(from: &container, forKey: key)
			dict[key.stringValue] = value
		}
		return dict
	}

	static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
		for value in array {
			if let value = value as? Bool {
				try container.encode(value)
			} else if let value = value as? Int64 {
				try container.encode(value)
			} else if let value = value as? Double {
				try container.encode(value)
			} else if let value = value as? String {
				try container.encode(value)
			} else if value is JSONNull {
				try container.encodeNil()
			} else if let value = value as? [Any] {
				var container = container.nestedUnkeyedContainer()
				try encode(to: &container, array: value)
			} else if let value = value as? [String: Any] {
				var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
				try encode(to: &container, dictionary: value)
			} else {
				throw encodingError(forValue: value, codingPath: container.codingPath)
			}
		}
	}

	static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
		for (key, value) in dictionary {
			let key = JSONCodingKey(stringValue: key)!
			if let value = value as? Bool {
				try container.encode(value, forKey: key)
			} else if let value = value as? Int64 {
				try container.encode(value, forKey: key)
			} else if let value = value as? Double {
				try container.encode(value, forKey: key)
			} else if let value = value as? String {
				try container.encode(value, forKey: key)
			} else if value is JSONNull {
				try container.encodeNil(forKey: key)
			} else if let value = value as? [Any] {
				var container = container.nestedUnkeyedContainer(forKey: key)
				try encode(to: &container, array: value)
			} else if let value = value as? [String: Any] {
				var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
				try encode(to: &container, dictionary: value)
			} else {
				throw encodingError(forValue: value, codingPath: container.codingPath)
			}
		}
	}

	static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
		if let value = value as? Bool {
			try container.encode(value)
		} else if let value = value as? Int64 {
			try container.encode(value)
		} else if let value = value as? Double {
			try container.encode(value)
		} else if let value = value as? String {
			try container.encode(value)
		} else if value is JSONNull {
			try container.encodeNil()
		} else {
			throw encodingError(forValue: value, codingPath: container.codingPath)
		}
	}

	public required init(from decoder: Decoder) throws {
		if var arrayContainer = try? decoder.unkeyedContainer() {
			self.value = try JSONAny.decodeArray(from: &arrayContainer)
		} else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
			self.value = try JSONAny.decodeDictionary(from: &container)
		} else {
			let container = try decoder.singleValueContainer()
			self.value = try JSONAny.decode(from: container)
		}
	}

	public func encode(to encoder: Encoder) throws {
		if let arr = self.value as? [Any] {
			var container = encoder.unkeyedContainer()
			try JSONAny.encode(to: &container, array: arr)
		} else if let dict = self.value as? [String: Any] {
			var container = encoder.container(keyedBy: JSONCodingKey.self)
			try JSONAny.encode(to: &container, dictionary: dict)
		} else {
			var container = encoder.singleValueContainer()
			try JSONAny.encode(to: &container, value: self.value)
		}
	}
}

//
//  CannedResponse.swift
//  Desk360LiveChat
//
//  Created by Alper Tabak on 23.02.2022.
//

import Foundation

internal enum CannedResponseSurveyType: Int {
	case good = 1
	case bad
}

// MARK: - CannedResponse
struct CannedResponse: Codable {
	let id: Int
	let actionableType: CannedResponseActionableType
	let isStart: Int
	let groupedUnits: GroupedUnits?

	enum CodingKeys: String, CodingKey {
		case id
		case actionableType = "actionable_type"
		case isStart = "is_start"
		case groupedUnits = "grouped_units"
	}
}

enum CannedResponseActionableType: String, Codable {
	case closeAndSurvey = "Close_and_survey"
	case replyButtons = "Reply_buttons"
	case user = "User"
	case group = "Group"
}

// MARK: - GroupedUnits
struct GroupedUnits: Codable {
	let button, message, closeMenuButton: [ResponseElement]?
	let output = [ResponseElement]()
	enum CodingKeys: String, CodingKey {
		case button = "Button"
		case message = "Message"
		case closeMenuButton = "Close_menu_button"
	}
	
	func getElements() -> [ResponseElement] {
		var result = [ResponseElement]()
		[self.message, self.button, self.closeMenuButton].forEach { response in
			guard let element = response else { return }
			result.append(contentsOf: element)
		}
		return result
	}
	
}

// MARK: - Button
struct ResponseElement: Codable {
	let id: Int
	let type: TypeEnum
	let actionableType: ButtonActionableType?
	let actionableID: Int?
	let orderID: Int
	let content: String
	let icon: Icon?
	var isSelected = false

	enum CodingKeys: String, CodingKey {
		case id, type
		case actionableType = "actionable_type"
		case actionableID = "actionable_id"
		case orderID = "order_id"
		case content, icon
	}
	
	mutating func setSelected(value: Bool) {
		self.isSelected = value
	}
}

extension ResponseElement {
	
	init(id: Int) {
		self.init(id: id, type: .closeMenuButton, actionableType: nil, actionableID: nil, orderID: 0, content: "", icon: nil)
	}
	
	func generateMessage(for customer: Bool) -> Message {
		let id = (self.actionableType == .closeAndSurvey) ? -1 : self.id
		return .init(
			id: String(describing: id),
			content: self.content,
			createdAt: .init(),
			updatedAt: .init(),
			senderName: "",
			agentID: nil,
			status: .sent,
			attachment: nil,
			isCustomer: customer,
			mediaItem: nil
		)
		
	}
	
}

enum ButtonActionableType: String, Codable {
	case closeAndSurvey = "Close_and_survey"
	case liveHelp = "Live_help"
	case path = "Path"
	case returnStartPath = "Return_start_path"
}

enum Icon: String, Codable {
	case cannedConnect = "canned-connect"
	case cannedHome = "canned-home"
	case cannedSurvey = "canned-survey"
}

enum TypeEnum: String, Codable {
	case button = "Button"
	case closeMenuButton = "Close_menu_button"
	case message = "Message"
	case survey
}

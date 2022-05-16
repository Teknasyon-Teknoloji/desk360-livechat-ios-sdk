//
//  CannedResponseViewModel.swift
//  Desk360LiveChat
//
//  Created by Alper Tabak on 23.02.2022.
//

import Foundation
import FirebaseAuth

protocol CannedResponseViewModelType: AnyObject {
	
	init(feedbackProvider: FeedbackProvider, agentProvider: AgentProvider, loginProvider: LoginProvider, router: Coordinator<MainRoute>)
	
	var delegate: CannedResponseViewModelDelegate? { get set }
	var numberOfUnits: Int { get }
	var latestUnitIndex: Int { get set }
	var statusHandler: ((BaseViewController.State) -> Void)? { get set }
	var resetHandler: (() -> Void)? { get set }
	
	func numberOfItemsIn(section: Int) -> Int
	func getCurrentPath(for indexPath: IndexPath) -> CannedResponse?
	func goToPath(id: Int)
	func setSelectedUnit(for element: ResponseElement)
	func sendFeedback(for survey: CannedResponseSurveyType)
	func returnToStartPosition()
	func arrangeSurvey()
	func back()
}

protocol CannedResponseViewModelDelegate: AnyObject {
	func reload()
    func basicReload()
}

final class CannedResponseViewModel: CannedResponseViewModelType {
	
	// MARK: - Properties
	weak var delegate: CannedResponseViewModelDelegate?
	public var currentPaths = [CannedResponse]()
	public var units = [ResponseElement]()
    public var sections = [[ResponseElement]]()
	public var latestUnitIndex = 0
	public var latestPathId = 0
	
	public var resetHandler: (() -> Void)?
	public var statusHandler: ((BaseViewController.State) -> Void)?
	
	private var onlineAgentAvailable = false
	private var loginHandler: ((Agent?) -> Void)?
	private var onlineAgentCount = 0
	private var disabledElementFlag = 0
	private var payloadCollector = CannedResponsePathCollector()
    private var messages = [MessageCellViewModel]()
	
	// MARK: - Computed Properties
	var numberOfUnits: Int {
		return self.units.count
	}

	// MARK: - Initialize Properties
	private let allPaths: [CannedResponse]
	private let feedbackProvider: FeedbackProvider
	private let agentProvider: AgentProvider
	private let loginProvider: LoginProvider
	private let router: Coordinator<MainRoute>
	
	// MARK: - Initializer
	init(
		feedbackProvider: FeedbackProvider,
		agentProvider: AgentProvider,
		loginProvider: LoginProvider,
		router: Coordinator<MainRoute>
	) {
		self.allPaths = Storage.settings.object?.cannedResponse ?? []
		self.feedbackProvider = feedbackProvider
		self.agentProvider = agentProvider
		self.loginProvider = loginProvider
		self.router = router
	}
	
	// MARK: - Methods
	func numberOfItemsIn(section: Int) -> Int {
		guard self.sections.indices.contains(section) else {
			return 0
		}
		
		return self.sections[section].count
	}
	
	func setSelectedUnit(for element: ResponseElement) {
        let lastSection = self.sections.count - 1
        guard self.sections.indices.contains(lastSection) else { return }
        guard let lastRow = self.sections.last?.lastIndex(where: { $0.id == element.id }) else { return }
        self.sections[lastSection][lastRow].setSelected(value: true)
		self.payloadCollector.append(element)
	}
	
	func goToPath(id: Int) {
		defer { self.latestPathId = id }
		guard let path = getResponseWithPath(id: id) else { return }
		
		if path.actionableType == .user || path.actionableType == .group {
			operateChatScreen(for: id)
			return
		}
		
		guard let elements = path.groupedUnits?.getElements() else { return }
		self.latestUnitIndex = units.count - 1
		units.append(contentsOf: elements)
        sections.append(elements)
		
        guard path.actionableType == .closeAndSurvey else {
            self.delegate?.reload()
            return
        }
        
        self.arrangeSurvey()
	}
	
	func returnToStartPosition() {
		currentPaths.removeAll()
		units.removeAll()
		sections.removeAll()
		self.resetHandler?()
		disabledElementFlag = 0
		self.latestUnitIndex = 0
		self.payloadCollector.reset()
		self.start()
	}
	
	func sendFeedback(for survey: CannedResponseSurveyType) {
		let payload = self.payloadCollector.getPayload()
		guard !payload.isEmpty else { return }
		guard latestPathId != 0 else { return }
		_ = self.feedbackProvider.send(pathId: self.latestPathId, type: survey, for: payload)
	}
	
	func arrangeSurvey() {
		let elem = ResponseElement(id: -1)
		units.append(elem)
		sections.append([elem])
        self.delegate?.reload()
	}
	
	public func getCurrentPath(for indexPath: IndexPath) -> CannedResponse? {
		guard currentPaths.indices.contains(indexPath.row) else {
			return nil
		}
		
		return currentPaths[indexPath.row]
	}
	
	public func getGroupedUnits(for indexPath: IndexPath) -> ResponseElement? {
        guard sections.indices.contains(indexPath.section) else { return nil }
        return sections[indexPath.section][indexPath.row]
	}
	
	public func findStartPoint() -> CannedResponse? {
		return allPaths.first(where: { $0.isStart == 1 })
	}
	
	public func getResponseWithPath(id: Int) -> CannedResponse? {
		return allPaths.first(where: { $0.id == id })
	}
	
	func operateChatScreen(for pathId: Int? = nil) {
		
		guard let credentials = getCredentials() else {
			self.presentChatOrLoginPage(for: nil)
			return
		}
		
		statusHandler?(.loading)

		getOnlineCountFromCompany { [weak self] onlineCount in
			guard let self = self else { return }
			
			guard onlineCount > 0 else {
				self.statusHandler?(.showingData)
				self.presentChatOrLoginPage(for: nil)
				return
			}
			self.login(path: pathId, payload: self.payloadCollector.getPayload())
		}
		
		loginHandler = { [weak self] agent in
			guard let self = self else { return }
			self.statusHandler?(.showingData)
			
			guard let agent = agent else {
				self.router.trigger(.chat(agent: nil, user: credentials, delegate: nil))
				return
			}
			self.presentChatOrLoginPage(for: agent)
		}
	}
	
	func back() {
		self.router.trigger(.popToRoot)
	}
	
}

extension CannedResponseViewModel {
	
	func start() {
		guard let startPoint = self.findStartPoint() else { return }
		currentPaths.append(startPoint)
		guard let elements = startPoint.groupedUnits?.getElements() else { return }
		units.append(contentsOf: elements)
        self.sections.append(elements)
		self.delegate?.basicReload()
	}
	
}

// MARK: - Chat Screen Related Methods
private extension CannedResponseViewModel {
	func getCredentials() -> Credentials? {
		return Storage.credentails.object
	}
	
	func getOnlineAgent() -> Future<Agent?, Error> {
		let uid = Auth.liveChat.currentUser?.uid ?? ""
		return agentProvider.getOnlineAgentInfo(uid: uid)
	}
	
	func login(path: Int? = nil, payload: [CannedResponsePayload]? = nil) {
		guard let creds = getCredentials() else {
			return
		}
		Session.shared
			.startFlowWith(credentials: creds, smartPlug: nil, path: path, payload: payload)
			.flatMap(getOnlineAgent)
			.observe(on: .main)
			.on(success: { agent in
				self.loginHandler?(agent)
			})
			
	}
	
	func presentChatOrLoginPage(for agent: Agent?, pathId: Int? = nil) {
		
		guard let agent = agent else {
			self.router.trigger(.login(isOnline: self.onlineAgentAvailable))
			return
		}
		
		guard let credentails = getCredentials() else {
			return
		}

		self.router.trigger(.chat(agent: agent, user: credentails, delegate: nil))
   }
	
	func getOnlineCountFromCompany(_ completion: @escaping (Int) -> Void) {
		let company = Storage.settings.object?.companyID ?? 0
        let application = Storage.settings.object?.applicationID ?? 0
		agentProvider.getOnlineAgentCount(for: company, applicationId: application)
			.on { onlineCount in
				self.onlineAgentCount = onlineCount ?? 0
				completion(self.onlineAgentCount)
			} failure: { error in
				Logger.log(event: .error, error)
				self.onlineAgentCount = 0
				
			}
	}
	
}

//
//  MainView.swift
//  Example
//
//  Created by Ali Ammar Hilal on 12.04.2021.
//

import SwiftUI
import UIKit

final class MainView: UIView, Layoutable {
    
    // MARK: - UI Elements
    lazy var welcomeContainer: TopContainer = {
        let view = TopContainer.create()
        return view
    }()
    
    lazy var chatContainer: ChatContainer = {
        let view = ChatContainer.create()
        view.isHidden = true
        return view
    }()
    
    lazy var faqContainer: FAQConatiner = {
        let view = FAQConatiner.create()
        return view
    }()
    
    lazy var activeConversationView: ActiveConversationView = {
        let view = ActiveConversationView.create()
        view.isHidden = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapActiveConversation)))
        return view
    }()
    
    private lazy var desk360LogoView: Desk360View = {
        let imageView = Desk360View()
        return imageView
    }()
    
    lazy var overallContainer: UIView = {
        let view = UIView()
        view.addSubview(welcomeContainer)
        view.addSubview(activeConversationView)
        view.addSubview(chatContainer)
        view.addSubview(faqContainer)
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.addSubview(overallContainer)
        scrollView.delegate = self
        return scrollView
    }()
    
    var activeConversationtanTaphandler: (() -> Void)?
    
    func setupViews() {
        backgroundColor = .white
        addSubview(scrollView)
        addSubview(desk360LogoView)
    }
    
    func setupStatusIfSessionActive(_ isActive: Bool) {
        chatContainer.isHidden = isActive
        activeConversationView.isHidden = !isActive
    }
    
    func setupLayout() { }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.anchor(
            top: safeAreaLayoutGuide.topAnchor,
            leading: leadingAnchor,
            bottom: desk360LogoView.topAnchor,
            trailing: trailingAnchor
        )
        
        overallContainer.fillSuperviewSafeAreaLayoutGuide()
        welcomeContainer.setSize(.init(width: frame.width, height: 230))
        welcomeContainer.anchor(
            top: overallContainer.topAnchor,
            leading: overallContainer.leadingAnchor,
            bottom: nil,
            trailing: overallContainer.trailingAnchor)
        
        chatContainer.anchor(
            top: welcomeContainer.bottomAnchor,
            leading: overallContainer.leadingAnchor,
            bottom: nil,
            trailing: overallContainer.trailingAnchor,
            padding: .init(top: -30, left: 20, bottom: 0, right: 20),
            size: .init(width: 0, height: 200)
        )
        
        activeConversationView.anchor(
            top: welcomeContainer.bottomAnchor,
            leading: overallContainer.leadingAnchor,
            bottom: nil,
            trailing: overallContainer.trailingAnchor,
            size: .init(width: 0, height: 70)
        )
        
        desk360LogoView
            .anchor(
                top: nil,
                leading: leadingAnchor,
                bottom: safeAreaLayoutGuide.bottomAnchor,
                trailing: trailingAnchor,
                size: .init(width: frame.width, height: 44)
            )
    }
}

// MARK: - UIScrollViewDelegate
extension MainView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
}

// MARK: - TopContainer
extension MainView {
    
    class TopContainer: UIView, Layoutable {
        lazy var companyLogoView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = Images.companyLogo.withRenderingMode(.alwaysOriginal)
            imageView.setSize(.init(width: 60, height: 60))
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 30
            return imageView
        }()
        
        lazy var titleMessage: UILabel = {
            let label = UILabel()
            label.text = Strings.loginWelcomeTitle
            label.textColor = config?.general.headerTitleColor.uiColor
            label.font = FontFamily.Gotham.bold.font(size: 26)
            return label
        }()
        
        lazy var subtitleMessage: UILabel = {
            let label = UILabel()
            label.text = Strings.loginWelcomeSubTitle.replacingOccurrences(of: "\n", with: "")
            label.numberOfLines = 0
            label.textColor = config?.general.headerSubTitleColor.uiColor
            label.font = FontFamily.Gotham.book.font(size: 15)
            return label
        }()
        
        lazy var closeButton: ActionButton = {
            let button = ActionButton(type: .system)
            let image = Images.close.tinted(with: config?.general.headerTitleColor.uiColor)
            button.setImage(image, for: .normal)
            return button
        }()
        
        private lazy var vStack: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [companyLogoView, titleMessage, subtitleMessage])
            stack.axis = .vertical
            stack.spacing = 12
            stack.alignment = .leading
            return stack
            
        }()
        
        func setupViews() {
            backgroundColor = config?.general.backgroundHeaderColor.uiColor
            addSubview(vStack)
            addSubview(closeButton)
            
            if let companyLogo = config?.general.brandLogo ?? Storage.settings.object?.applicationLogo  {
                companyLogoView.kf.setImage(with: URL(string: companyLogo), placeholder: Images.avatarPlacegolder)
            } else if let url = Storage.settings.object?.defaultBrandLogo  {
                companyLogoView.kf.setImage(with: URL(string: url))
            } else {
                companyLogoView.image = Images.avatarPlacegolder
            }
        }
        
        func setupLayout() {
            
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            closeButton.anchor(
                top: safeAreaLayoutGuide.topAnchor,
                leading: nil,
                bottom: nil,
                trailing: trailingAnchor,
                padding: .init(top: 20, left: 20, bottom: 0, right: 20)
            )
            
            subtitleMessage.widthAnchor.constraint(equalToConstant: frame.width).isActive = true
            
            vStack.anchor(
                top: safeAreaLayoutGuide.topAnchor,
                leading: leadingAnchor,
                bottom: nil,
                trailing: trailingAnchor,
                padding: .init(top: 20, left: 20, bottom: 0, right: 20)
            )
        }
    }
}

// MARK: - CompanyInfo
extension MainView {
    
    class ChatContainer: UIView, Layoutable {
        lazy var companyName: UILabel = {
            let label = UILabel()
            label.text = Strings.companyName
            label.font = FontFamily.Gotham.medium.font(size: 16)
            label.textColor = config?.general.backgroundHeaderColor.uiColor
            return label
        }()
        
        lazy var seperator: UIView = {
            let view = UIView()
            view.heightAnchor.constraint(equalToConstant: 1).isActive = true
            view.backgroundColor = UIColor.cadetBlue.withAlphaComponent(0.5)
            return view
        }()
        
        lazy var titleLable: UILabel = {
            let label = UILabel()
            label.text = Strings.startChatContainerHeader
            label.textColor = config?.general.sectionHeaderTitleColor.uiColor
            label.font = FontFamily.Gotham.medium.font(size: 17)
            return label
        }()
        
        lazy var subtitleLabel: UILabel = {
            let label = UILabel()
            label.text = Strings.startChatContainerSubTitle
            label.font = FontFamily.Gotham.book.font(size: 14)
            label.textColor = config?.general.sectionHeaderTextColor.uiColor
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .center
            return label
        }()
        
        lazy var startChatButton: ActionButton = {
            let button = ActionButton(type: .system)
            button.lockable = true
            button.setTitle(Strings.startChatSendMessageButtonText, for: .normal)
            button.setTitleColor(config?.general.sendButtonTextColor.uiColor, for: .normal)
            button.setImage(Images.send.tinted(with: config?.general.sendButtonTextColor.uiColor), for: .normal)
            button.backgroundColor = config?.general.sendButtonBackgroundColor.uiColor
            button.imageEdgeInsets.left = -20
            button.layer.cornerRadius = 22
            button.titleLabel?.font = FontFamily.Gotham.medium.font(size: 14)
            return button
        }()
        
        private lazy var vStack: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [titleLable, subtitleLabel, startChatButton])
            stack.axis = .vertical
            stack.spacing = 8
            stack.alignment = .center
            return stack
        }()
        
        func setupViews() {
            backgroundColor = .white
            layer.cornerRadius = 8
            addSubview(companyName)
            addSubview(seperator)
            addSubview(vStack)
        }
        
        func setupLayout() {
            companyName.centerXTo(centerXAnchor)
            companyName.anchor(top: topAnchor, padding: .init(top: 12, left: 0, bottom: 0, right: 0))
            
            startChatButton.setSize(.init(width: 250, height: 44))
            
            seperator.constrainHeight(1)
            seperator.anchor(
                top: companyName.bottomAnchor,
                leading: leadingAnchor,
                bottom: nil,
                trailing: trailingAnchor,
                padding: .init(top: 10, left: 20, bottom: 0, right: 20)
            )
            
            vStack.anchor(
                top: seperator.bottomAnchor,
                leading: leadingAnchor,
                bottom: bottomAnchor,
                trailing: trailingAnchor,
                padding: .init(top: 10, left: 10, bottom: 10, right: 10)
            )
            
            vStack.setCustomSpacing(20, after: subtitleLabel)
            setupShadow(opacity: 0.5, radius: 4, offset: .zero, color: UIColor.santasGray)
        }
    }
}

extension MainView {
    
    class FAQConatiner: UIView, Layoutable {
        
        lazy var titleLable: UILabel = {
            let label = UILabel()
            label.font = FontFamily.Gotham.medium.font(size: 16)
            label.textColor = .martinique
            label.text = Strings.faqContainerTitle
            label.textAlignment = .center
            return label
        }()
        
        lazy var searchBar: UISearchBar = {
            let searchBar = UISearchBar()
            searchBar.placeholder = Strings.faqSearchPlaceholder
            searchBar.backgroundColor = .clear
            searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
            searchBar.searchField?.textColor = .martinique
            searchBar.searchField?.layer.cornerRadius = 18
            searchBar.searchField?.backgroundColor = UIColor(hex: "#f3f5f8")
            searchBar.searchField?.clipsToBounds = true
            return searchBar
        }()
        
        lazy var topStack: UIView = .vStack(
            alignment: .center,
            distribution: .equalCentering,
            spacing: 15,
            margins: .all(8),
            [titleLable, searchBar]
        )
        
        lazy var popularFaqsTable: UITableView = {
            let table = UITableView()
            // table.estimatedRowHeight = 50
            table.register(cellType: FaqBaseCell.self)
            table.register(cellType: FaqDetailTableViewCell.self)
            table.tableFooterView = UIView()
            table.separatorStyle = .none
            return table
        }()
        
        func setupViews() {
            backgroundColor = .white
            searchBar.backgroundColor = .clear
            
            addSubview(topStack)
            addSubview(popularFaqsTable)
        }
        
        func setupLayout() {
            topStack.anchor(
                top: topAnchor,
                leading: leadingAnchor,
                bottom: nil,
                trailing: trailingAnchor)
            
            searchBar.setSize(.init(width: 300, height: 44))
            topStack.centerXToSuperview()
            
            popularFaqsTable.anchor(
                top: searchBar.bottomAnchor,
                leading: leadingAnchor,
                bottom: bottomAnchor,
                trailing: trailingAnchor,
                padding: .init(v: 8, h: 0),
                size: .init(width: 0, height: 300)
            )
            
            layer.cornerRadius = 8
            popularFaqsTable.addBorders(edges: .top, color: UIColor.santasGray.withAlphaComponent(0.1))
            topStack.addBorders(edges: [.top, .left, .right], color: UIColor.santasGray.withAlphaComponent(0.1))
        }
    }
}

private extension MainView {
    @objc private func didTapActiveConversation() {
        activeConversationtanTaphandler?()
    }
}

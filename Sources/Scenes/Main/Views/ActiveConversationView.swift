//
//  ActiveAgentView.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 19.04.2021.
//

import UIKit

final class ActiveConversationView: UIView, Layoutable {
    
    lazy var agentAvatar: UIImageView = {
        let view = UIImageView()
        view.setSize(.init(width: 40, height: 40))
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    lazy var agentName: UILabel = {
        let label = UILabel()
        label.textColor = config?.general.sectionHeaderTitleColor.uiColor
        label.font = FontFamily.Gotham.medium.font(size: 17)
        label.text = "Harsha Buksh"
        
        return label
    }()
    
    lazy var questionHeadline: UILabel = {
        let label = UILabel()
        label.textColor = .martinique
        label.font = FontFamily.Gotham.book.font(size: 15)
        label.text = "I have signed up to get new features"
        label.numberOfLines = 1
        label.textColor = .santasGray
        return label
    }()
    
    lazy var agentStatusIndicator: UIView = {
        let view = UIView()
        view.setSize(.init(width: 14, height: 14))
        view.layer.cornerRadius = 7
        view.clipsToBounds = true
        view.backgroundColor = UIColor(hex: "#31c432")
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    
    lazy var startChatButton: ActionButton = {
        let button = ActionButton()
        button.lockable = true
        button.setSize(.init(width: 32, height: 32))
        button.setImage(Images.startChat, for: .normal)
        button.backgroundColor = .blueRibbon
        button.layer.cornerRadius = 16
        return button
    }()
    
    lazy var stack: UIView = .hStack(
        alignment: .leading,
        distribution: .fill,
        spacing: 8, [
            agentAvatar,
            .vStack([agentName, questionHeadline]),
            .spacer(),
            startChatButton
        ])
    
    func setupViews() {
        addSubview(stack)
        addSubview(agentStatusIndicator)
        backgroundColor = .white
    }
    
    func setupLayout() { }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stack.fillSuperview(padding: .init(v: 15, h: 20))
        agentStatusIndicator.anchor(
            top: nil,
            leading: nil,
            bottom: agentAvatar.bottomAnchor,
            trailing: agentAvatar.trailingAnchor,
            padding: .init(top: 0, left: 0, bottom: 2, right: -2)
        )
        
        addBorders(edges: .bottom, color: UIColor(hex: "#e3e6eb") ?? .cadetBlue, inset: 20, thickness: 1)
    }
    
    func configure(with conversation: RecentMessage) {
        let agent = conversation.agent
        let textColor = config?.general.sectionHeaderTitleColor.uiColor ?? .dodgerBlue
        setAgentName(for: agent)
        questionHeadline.text = conversation.message.content
        questionHeadline.textColor = textColor
        if let attachment = conversation.message.attachment {
            let messageType = attachment.mapToMessageType()
            switch messageType {
            case .document:
                questionHeadline.set(text: Strings.sdk_document, leftIcon: Images.fileAttachment.maskWithColor(color: textColor))
            case .photo:
                questionHeadline.set(text: Strings.sdk_photo, leftIcon: Images.imageAttachment.maskWithColor(color: textColor))
            case .video:
                questionHeadline.set(text: Strings.sdk_video, leftIcon: Images.videoAttachment.maskWithColor(color: textColor))
            default:
                break
            }
        } else if let media = conversation.message.mediaItem {
            let messageType = media.type
            switch messageType {
            case .files, .others:
                questionHeadline.set(text: Strings.sdk_document, leftIcon: Images.fileAttachment.maskWithColor(color: textColor))
            case .images:
                questionHeadline.set(text: Strings.sdk_photo, leftIcon: Images.imageAttachment.maskWithColor(color: textColor))
            case .videos:
                questionHeadline.set(text: Strings.sdk_video, leftIcon: Images.videoAttachment.maskWithColor(color: textColor))
            default:
                break
            }
        }
        
        setAgentImage(agent)
    }
	
	private func setAgentName(for agent: Agent) {
		guard let settings = Storage.settings.object else { return }
		
		if let showName = settings.config.online.showAgentName, showName {
			agentName.text = agent.name
			return
		}
		
		if let brandName = settings.config.general.brandName {
			agentName.text = brandName
			return
		}
		
		if let appName = settings.applicationName {
			agentName.text = appName
			return
		}
		
	}
    
    private func setAgentImage(_ agent: Agent?) {
        guard let url = avatarURL(agent: agent) else {
            // agentAvatar.image = Images.avatarPlacegolder
            agentAvatar.kf.setImage(with: URL(string: Storage.settings.object?.defaultBrandLogo ?? ""))
            return
        }
        
        agentAvatar.kf.setImage(with: url, placeholder: Images.avatarPlacegolder)
    }
    
    private func avatarURL(agent: Agent?) -> URL? {
        let shouldShowAvatar = config?.general.agentPictureStatus ?? false
        if let agent = agent, let avatarUrl = URL(string: agent.avatar), shouldShowAvatar {
            return avatarUrl
        } else if let avatarUrl = URL(string: config?.general.brandLogo ?? Storage.settings.object?.applicationLogo ?? "") {
            // agentAvatar.image = Images.avatarPlacegolder
            agentAvatar.kf.setImage(with: URL(string: Storage.settings.object?.defaultBrandLogo ?? ""))
            return avatarUrl
        }
        return nil
    }
}

extension UILabel {
    
    func set(text: String, leftIcon: UIImage? = nil, rightIcon: UIImage? = nil) {
        
        let leftAttachment = NSTextAttachment()
        if let leftIcon = leftIcon {
            leftAttachment.image = leftIcon
            leftAttachment.bounds = CGRect(x: 0, y: 0, width: leftIcon.size.width, height: leftIcon.size.height)
        }
        let leftAttachmentStr = NSAttributedString(attachment: leftAttachment)
        
        let myString = NSMutableAttributedString(string: "")
        
        let rightAttachment = NSTextAttachment()
        rightAttachment.image = rightIcon
        rightAttachment.bounds = CGRect(x: 0, y: -5, width: 24, height: 24)
        let rightAttachmentStr = NSAttributedString(attachment: rightAttachment)
        
        if semanticContentAttribute == .forceRightToLeft {
            if rightIcon != nil {
                myString.append(rightAttachmentStr)
                myString.append(NSAttributedString(string: " "))
            }
            myString.append(NSAttributedString(string: text))
            if leftIcon != nil {
                myString.append(NSAttributedString(string: " "))
                myString.append(leftAttachmentStr)
            }
        } else {
            if leftIcon != nil {
                myString.append(leftAttachmentStr)
                myString.append(NSAttributedString(string: " "))
            }
            myString.append(NSAttributedString(string: text))
            if rightIcon != nil {
                myString.append(NSAttributedString(string: " "))
                myString.append(rightAttachmentStr)
            }
        }
        attributedText = myString
    }
}

extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        color.setFill()
        self.draw(in: rect)
        
        context.setBlendMode(.sourceIn)
        context.fill(rect)
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
    
}

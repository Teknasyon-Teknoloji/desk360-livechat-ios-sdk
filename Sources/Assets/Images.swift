//
//  Images.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 14.04.2021.
//

import UIKit

struct Images {
	private init() {}

    static func createImage(resources: String) -> UIImage {
		guard let path = Bundle.assetsBundle?.path(forResource: resources, ofType: "png") else { return UIImage() }
		guard let image = UIImage(contentsOfFile: path) else { return UIImage() }
		return image.withRenderingMode(.alwaysOriginal)
	}
	
	private static func createImageOriginal(resources: String) -> UIImage {
		guard let path = Bundle.assetsBundle?.path(forResource: resources, ofType: "png") else { return UIImage() }
		guard let image = UIImage(contentsOfFile: path) else {
			return UIImage()
		}
		
		return image.withRenderingMode(.alwaysOriginal)
	}

	static var send: UIImage = {
		return Images.createImage(resources: "Images/send-white")
		// VGPlayer_ic_slider_thumb
	}()

	static var desk360: UIImage = {
		return Images.createImage(resources: "Images/desk360")
	}()

	static var close: UIImage = {
		return Images.createImage(resources: "Images/close")
	}()

	static var companyLogo: UIImage = {
		return Images.createImage(resources: "Images/bitmap")
	}()
	
	static var ribbon: UIImage = {
		return Images.createImage(resources: "Images/ribbon")
	}()
	
	static var startChat: UIImage = {
		return Images.createImage(resources: "Images/start")
	}()
	
	static var back: UIImage = {
		return Images.createImage(resources: "Images/back")
	}()
	
	static var options: UIImage = {
		return Images.createImage(resources: "Images/options")
	}()
	
	static var downArrow: UIImage = {
		return Images.createImage(resources: "Images/down_arrow")
	}()
	
	static var sendChat: UIImage = {
		return Images.createImage(resources: "Images/send")
	}()
	
	static var emoji: UIImage = {
		return Images.createImage(resources: "Images/emoji")
	}()
	
	static var attacment: UIImage = {
		return Images.createImage(resources: "Images/attacment")
	}()
	
	static var alertIcon: UIImage = {
		return Images.createImage(resources: "Images/alert-circle-1")
	}()
	
	static var aviIcon: UIImage = {
		return Images.createImage(resources: "Images/avi")
	}()
	
	static var videoIcon: UIImage = {
		return Images.createImage(resources: "Images/video")
	}()
	
	static var download: UIImage = {
		return Images.createImage(resources: "Images/download")
	}()
	
	static var offlineMessage: UIImage = {
		return Images.createImage(resources: "Images/message_logo")
	}()
	
	static var like: UIImage = {
		return Images.createImage(resources: "Images/like")
	}()
	
	static var dislike: UIImage = {
		return Images.createImage(resources: "Images/dislike")
	}()
	
	static var successTick: UIImage = {
		return Images.createImage(resources: "Images/tick")
	}()
	
	static var imagepreview: UIImage = {
		return Images.createImage(resources: "Images/image_preview")
	}()
	
	static var play: UIImage = {
		return Images.createImage(resources: "Images/play")
	}()
	
	static var deliveredTick: UIImage = {
		return Images.createImage(resources: "Images/delivered_tick")
	}()
	
	static var sentTick: UIImage = {
		return Images.createImage(resources: "Images/sent_tick")
	}()
	
	static var readTick: UIImage = {
		return Images.createImage(resources: "Images/read_tick")
	}()
	
	static var VGPlayer_ic_slider_thumb: UIImage = {
		return Images.createImage(resources: "Images/slider-thumb")
	}()
    
    static var showRecentMessages: UIImage = {
        return Images.createImage(resources: "Images/arrow-down_background")
    }()
    
    static var avatarPlacegolder: UIImage = {
        return Images.createImage(resources: "Images/avatar_placeholder")
    }()
    
    static var thumbsUp: UIImage = {
        return Images.createImage(resources: "Images/thumbs-up")
    }()
    
    static var thumbsDown: UIImage = {
        return Images.createImage(resources: "Images/thumbs-down")
    }()
    
    static var success: UIImage = {
        return Images.createImage(resources: "Images/sucess")
    }()
    
    static var noInternet: UIImage = {
        return Images.createImage(resources: "Images/internet")
    }()
    
    static var info: UIImage = {
        return Images.createImage(resources: "Images/info")
    }()
    
    static var fileAttachment: UIImage = {
        return Images.createImage(resources: "Images/file")
    }()
    
    static var videoAttachment: UIImage = {
        return Images.createImage(resources: "Images/video-camera (1)")
    }()
    
    static var imageAttachment: UIImage = {
        return Images.createImage(resources: "Images/imageAttachment")
    }()
    
    static var scrollDown: UIImage = {
        return Images.createImage(resources: "Images/scroll_down")
    }()
}

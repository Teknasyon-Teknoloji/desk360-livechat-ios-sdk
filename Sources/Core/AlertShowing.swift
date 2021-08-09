//
//  AlertShowing.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 1.07.2021.
//

import UIKit

protocol AlertShowing: AnyObject {
    
    func showAlert(type: PopupType, title: String?, message: String?, actionTitle: String, _ actionHandler: (() -> Void)?)
}

enum AlertType {
    case info
    case warning
    case error
    case success
}

enum AlertButtonType: String {
    case ok
    case cancel
    case yes
    case no
    
    var localized: String {
        switch self {
        case .ok:
            return "OK"
        case .cancel:
            return "Cancel"
        case .yes:
            return "Yes"
        case .no:
            return "No"
        }
    }
}

extension AlertShowing where Self: UIViewController {
    
    func showAlert(
        type: PopupType,
        title: String?,
        message: String?,
        actionTitle: String = "OK",
        _ actionHandler: (() -> Void)? = nil
    ) {
        let topVc = UIApplication.topViewController() ?? self
        PopupManager.shared.show(popupType: type, on: topVc, title: title ?? "", message: message ?? "", action: actionHandler)
    }
    
    func showAlertWithButtons(withType alertType: AlertType? = .info, title: String? = "", message: String, buttons: [String]? = nil, completion: ((Int) -> Void)! = nil) {
        
        var defaultButtons: [String] = []
        
        defaultButtons = [AlertButtonType.ok.localized]
        
        let buttons = buttons ?? defaultButtons
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        buttons.enumerated().forEach { index, value in
            
            let action = UIAlertAction(title: value, style: .default) { _ in
                completion?(index)
            }
            
            alert.addAction(action)
            
            present(alert, animated: true)
        }
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

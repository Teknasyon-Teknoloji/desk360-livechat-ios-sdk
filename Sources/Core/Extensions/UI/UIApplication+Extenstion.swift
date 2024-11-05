//
//  UIApplication+Extenstion.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 22.04.2021.
//

import UIKit

extension UIApplication {
	var statusBarUIView: UIView? {

		if #available(iOS 13.0, *) {
			let tag = 3848245

			let keyWindow = UIApplication
				.shared
				.connectedScenes
				.compactMap { $0 as? UIWindowScene }
				.first?
				.windows
				.first

			if let statusBar = keyWindow?.viewWithTag(tag) {
				return statusBar
			} else {
				var statusBarFrame = keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
                statusBarFrame.size.height = keyWindow?.safeAreaInsets.top ?? 0

                let statusBarView = UIView(frame: statusBarFrame)
				statusBarView.tag = tag
				statusBarView.layer.zPosition = 999999

				keyWindow?.addSubview(statusBarView)
				return statusBarView
			}

		} else {

			if responds(to: Selector(("statusBar"))) {
				return value(forKey: "statusBar") as? UIView
			}
		}
		return nil
	}
}

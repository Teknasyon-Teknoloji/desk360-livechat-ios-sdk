//
//  ActionButton.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 27.04.2021.
//

import UIKit

class ActionButton: UIButton {
	var action: (() -> Void)?
    var lockable: Bool = false
    
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.isExclusiveTouch = true
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.addTarget(self, action: #selector(self.didTapSelf), for: .touchUpInside)
		}
	}
	
	@available(*, unavailable, message: "init(coder:) has not been implemented")
	required init?(coder: NSCoder) { fatalError() }
	
	@objc private func didTapSelf() {
		
		defer {
            if lockable {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                    self.isUserInteractionEnabled = true
                })
            }
		}
		
        if lockable {
            self.isUserInteractionEnabled = false
        }
		DispatchQueue.main.async { [weak self] in
			self?.action?()
		}
	}
}

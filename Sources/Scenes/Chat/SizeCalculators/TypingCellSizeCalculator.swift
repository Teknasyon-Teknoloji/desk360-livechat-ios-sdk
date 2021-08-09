//
//  TypingCellSizeCalculator.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 14.05.2021.
//

import UIKit

class TypingCellSizeCalculator: CellSizeCalculator {

	init(layout: MessagesCollectionViewFlowLayout? = nil) {
		super.init()
		self.layout = layout
	}

	override func sizeForItem(at indexPath: IndexPath) -> CGSize {
		return .init(width: 50, height: 30)
	}
}

//
//  UISearchBar+Extensions.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 22.04.2021.
//

import UIKit

extension UISearchBar {
	var searchField: UITextField? {
		if #available(iOS 13.0, *) {
			return self.searchTextField
		} else {
			if let textfield = value(forKey: "searchField") as? UITextField { return textfield }
		}
		
		return nil
	}
	
	var backgroundView: UIView? {
		searchField?.layer.borderWidth = 0
		searchField?.backgroundColor = .clear
		searchField?.leftView = nil
		if let backgroundview = searchField?.subviews.first {
				// backgroundview.backgroundColor = UIColor.white
				backgroundview.layer.cornerRadius = 4
				backgroundview.clipsToBounds = true
			return backgroundview
		}
		
		return nil
	}
}

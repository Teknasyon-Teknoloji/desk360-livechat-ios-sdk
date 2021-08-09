//
//  Database+Path.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 29.04.2021.
//

import FirebaseDatabase

extension Database {
	func reference(to path: FirebasePath) -> DatabaseReference {
		return reference(withPath: path.path)
	}
}

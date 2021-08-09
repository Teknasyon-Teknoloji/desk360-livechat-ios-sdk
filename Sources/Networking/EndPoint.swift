//
//  EndPoint.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 22.04.2021.
//

import Foundation

struct Endpoint {
	let path: String
	let queryItems: [URLQueryItem]
}

extension Endpoint {
	var url: URL {
		var components = URLComponents()
		components.scheme = "https"
		components.host = Environmet.current.baseURL
		components.path = path
		components.queryItems = queryItems
		guard let url = components.url else { fatalError("Cant construct url") }
		return url
	}
	
}

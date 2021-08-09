//
//  Interceptor.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 22.04.2021.
//

import Alamofire
import Foundation

class RequestInterceptor: Alamofire.RequestInterceptor {
	
	func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
		var request = urlRequest
        request.setValue(Storage.appKey.object() ?? "", forHTTPHeaderField: "Authorization")
	    request.setValue( "application/json", forHTTPHeaderField: "Content-Type")
		completion(.success(urlRequest))
	}
	
}

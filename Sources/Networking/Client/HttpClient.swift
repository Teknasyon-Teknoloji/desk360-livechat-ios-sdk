//
//  HttpClient.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 22.04.2021.
//

import Alamofire
import Foundation

class HttpClient {
	
	static let shared = HttpClient()
	
	private let interceptor: RequestInterceptor

	var headers: HTTPHeaders {
        let appKey = Storage.appKey.object() ?? ""
		return .init([
			"Authorization": appKey,
			"Content-Type": "application/json"
		])
	}
	
	init(interceptor: RequestInterceptor = RequestInterceptor()) {
		self.interceptor = interceptor
	}

	func get<T: Codable>(from endPoint: Endpoint, parameters: [String: String]) -> Future<T, Error> {
		let promise = Promise<T, Error>()
		AF.request(
			endPoint.url,
			method: .get,
			parameters: parameters,
			encoding: URLEncoding.default,
			headers: headers,
			interceptor: interceptor
		).responseDecodable(of: BaseResponse<T>.self) { dataResponse in
				switch dataResponse.result {
				case .success(let object):
					if let object = object.data {
						promise.succeed(value: object)
					} else {
						promise.fail(error: AnyError(message: object.meta?.message))
					}
				case .failure(let error):
                 
					promise.fail(error: error)
				}
        }.cURLDescription { string in
            print(string)
        }
        
		return promise.future
			
	}
	
	/// Make POST request to the given path with JSON body encoding
	/// - Parameters:
	///   - path: the end point path
	///   - parameters: The json body parameters
	/// - Returns: The decoded response
	func post<T: Codable>(to endpoint: Endpoint, parameters: [String: String]) -> Future<T, Error> {
		let promise = Promise<T, Error>()
		AF.request(
			endpoint.url,
			method: .post,
			parameters: parameters,
			encoder: URLEncodedFormParameterEncoder(destination: .queryString),
			headers: headers,
			interceptor: interceptor
		).cURLDescription(calling: { curl in
			Logger.log(event: .info, curl)
		})
		.responseDecodable(of: BaseResponse<T>.self) { dataResponse in
				switch dataResponse.result {
				case .success(let object):
					if let object = object.data {
						promise.succeed(value: object)
					} else {
						promise.fail(error: AnyError(message: object.meta?.message))
					}
				case .failure(let error):
                    Logger.logError(error)
					promise.fail(error: error)
				}
			}
		return promise.future
	}
}

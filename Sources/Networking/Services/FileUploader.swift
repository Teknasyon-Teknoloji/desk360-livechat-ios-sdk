//
//  FileUploader.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 17.05.2021.
//

import Alamofire
import Foundation

protocol FileUploader {
	func upload(file: File, progress: @escaping((CGFloat) -> Void), then completion: @escaping((Result<Attachment?, AFError>) -> Void))
}

final class FileUploading: FileUploader {
	private let uploadUrl = URL(string: "https://" + Environmet.current.baseURL + "/api/v1/chat/sdk/file-upload")!
	
	var headers: HTTPHeaders {
        let appKey = Storage.appKey.object() ?? ""
        return .init([
            "Authorization": appKey,
            "Content-Type": "application/json"
        ])
	}

	func upload(file: File, progress: @escaping((CGFloat) -> Void), then completion: @escaping((Result<Attachment?, AFError>) -> Void)) {
		let formData = MultipartFormData()
		formData
			.append(
				file.content,
				withName: "attachments[]",
				fileName: file.name + ".\(file.extension.rawValue)",
				mimeType: file.extension.rawValue
			)

		AF.upload(
				multipartFormData: formData,
				to: uploadUrl,
				usingThreshold: .max,
				method: .post,
				headers: headers,
				interceptor: RequestInterceptor(),
				fileManager: .default
		).uploadProgress(queue: .main) { aProgress in
			progress(CGFloat(aProgress.fractionCompleted))
		}
		.responseString(completionHandler: { res in
			print(res)
		})
		.responseDecodable(of: BaseResponse<Attachment>.self) { response in
			let result = response.result.map { $0.data }
			print(result)
			completion(result)
		}
	}
}

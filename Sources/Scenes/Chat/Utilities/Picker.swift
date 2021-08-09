//
//  Picker.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 17.05.2021.
//

import Photos
import UIKit

final class Picker: NSObject, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	typealias PickerHandler = (String, Kind) -> Void
	
	enum Source {
		case document
		case media
	}
	
	enum Kind {
		case video(item: ChatMediaItem)
		case picture(item: ChatMediaItem)
		case file(item: ChatMediaItem)
	}
	
	private var pickerHandler: PickerHandler?
	private weak var presenter: (UIViewController & AlertShowing)?
	
	init(presenter: UIViewController & AlertShowing) {
		self.presenter = presenter
		super.init()
	}
	
	func pick(from source: Source, then completion: @escaping PickerHandler) {
		self.pickerHandler = completion
		switch source {
		case .document:
			pickDocument()
		case .media:
			pickMedia()
		}
	}
	
	private func pickDocument() {
		let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf", "com.microsoft.word.doc", "com.microsoft.excel.xls", "org.openxmlformats.spreadsheetml.sheet"], in: .import)
		documentPicker.delegate = self
		documentPicker.modalPresentationStyle = .fullScreen
		self.presenter?.present(documentPicker, animated: true)
	}
	
	private func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}
	
	private func pickMedia() {
		let imagePicker: UIImagePickerController = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.modalPresentationStyle = .fullScreen
		imagePicker.allowsEditing = false
		imagePicker.mediaTypes = ["public.image", "public.movie"]
		imagePicker.sourceType = .photoLibrary
		
		PHPhotoLibrary.requestAuthorization { status in
			if status == .authorized {
				DispatchQueue.main.async {
					self.presenter?.present(imagePicker, animated: true)					
				}
			}
		}
	}
	
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		guard let url = urls.first else { return }
		guard let pdfData = try? Data(contentsOf: url) else { return }
		guard let name = url.pathComponents.last else { return }
		let fileExtension = File.Extension(rawValue: name.fileExtension.lowercased()) ?? .pdf
		// Logger.log(event: .info, "Did pick document: \(name) of type: \(fileExtension.rawValue)")
		guard pdfData.count < 20971520 else {
            presenter?.showAlert(type: .info, title: Strings.title, message: Strings.sdk_file_limit, actionTitle: Strings.sdk_ok, nil)
			controller.dismiss(animated: true)
			return
		}
		
		let item = ChatMediaItem(fileName: name, url: url, image: nil, data: pdfData, placeholderImage: nil, mediaExtension: fileExtension, type: .files)
		pickerHandler?(name, .file(item: item))
		controller.dismiss(animated: true)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		
		if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            guard let imgUrl = info[.imageURL] as? URL else { return }
            var name = imgUrl.pathComponents.last ?? UUID.init().uuidString
            if #available(iOS 11.0, *) {
                if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
                    let assetResources = PHAssetResource.assetResources(for: asset)
                    name = assetResources.first?.originalFilename ?? UUID().uuidString
                }
            }
			guard let data = image.jpegData(compressionQuality: 0.7) else { return }
			guard data.count < 20971520 else {
                presenter?.showAlert(type: .info, title: Strings.title, message: Strings.sdk_file_limit, actionTitle: Strings.sdk_ok, nil)
				picker.dismiss(animated: true)
				return
			}
			let item = ChatMediaItem(fileName: name, url: imgUrl, image: image, data: data, placeholderImage: image, mediaExtension: .jpeg, type: .images)
			pickerHandler?(name, .picture(item: item))
			
		} else {
			if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                let name = videoUrl.pathComponents.last ?? UUID().uuidString + ".mp4"
				// Logger.Log("Did pick a video \(name)")
				guard let data = try? Data(contentsOf: videoUrl as URL, options: .mappedIfSafe) else { return }
				guard data.count < 20971520 else {
                    presenter?.showAlert(type: .info, title: Strings.title, message: Strings.sdk_file_limit, actionTitle: Strings.sdk_ok, nil)
					picker.dismiss(animated: true)
					return
				}
				
				let item = ChatMediaItem(fileName: name, url: videoUrl, image: nil, data: data, placeholderImage: nil, mediaExtension: .init(rawValue: name.fileExtension) ?? .mp4, type: .videos)
				pickerHandler?("video\(name.fileExtension)", .video(item: item))
			}
		}
		picker.dismiss(animated: true)
	}
}

extension Picker.Kind {
	var item: ChatMediaItem {
		switch self {
		case let .file(item): return item
		case let .picture(item): return item
		case let .video(item): return item
		}
	}
	
}

extension String {
	var fileExtension: String {
		(self.components(separatedBy: ".").last ?? "").lowercased()
	}
}

//
//  File.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 30.06.2021.
//

import Foundation

// swiftlint:disable force_unwrapping
struct File: Codable {
    let name: String
    let content: Data
    let `extension`: Extension
    let attachedMessageID: String
}

extension File {
    struct Extension: RawRepresentable, Codable {
        var rawValue: String
        
        init?(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension File.Extension {
    static let png     = File.Extension(rawValue: "png")!
    static let pdf     = File.Extension(rawValue: "pdf")!
    static let mp4     = File.Extension(rawValue: "mp4")!
    static let jpeg = File.Extension(rawValue: "jpeg")!
}
// swiftlint:enable force_unwrapping

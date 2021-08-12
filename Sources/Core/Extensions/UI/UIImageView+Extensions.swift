//
//  UIImage+Extensions.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 22.04.2021.
//

import UIKit

extension UIImage {
    func tinted(with color: UIColor?, isOpaque: Bool = false) -> UIImage? {
        let color = color ?? .white
        var image: UIImage
        if #available(iOS 13.0, *) {
            
            image = withTintColor(color)
        } else {
            let format = imageRendererFormat
            format.opaque = isOpaque
            withRenderingMode(.alwaysTemplate)
            image = UIGraphicsImageRenderer(size: size, format: format).image { _ in
                color.set()
                withRenderingMode(.alwaysTemplate).draw(at: .zero)
            }
            
        }
        return image
    }
}

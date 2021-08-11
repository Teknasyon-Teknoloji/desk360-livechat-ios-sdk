//
//  UIImage+Extensions.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 6.07.2021.
//

import UIKit

extension UIImage {
    func withBackground(color: UIColor, opaque: Bool = false) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
        guard let ctx = UIGraphicsGetCurrentContext(), let image = cgImage else { return self }
        defer { UIGraphicsEndImageContext() }
        
        let rect = CGRect(origin: .zero, size: size)
        ctx.setFillColor(color.cgColor)
        ctx.fill(rect)
        ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
        ctx.draw(image, in: rect)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
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

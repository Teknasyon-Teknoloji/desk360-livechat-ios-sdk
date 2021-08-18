//
//  Desk360LogoView.swift
//  Desk360LiveChat
//
//  Created by Ali Ammar Hilal on 12.08.2021.
//

import UIKit

/// This view using for bottom desk360 bottom bar
final class Desk360View: UIView {

    private lazy var desk360LogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Images.desk360
        return imageView
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = config?.general.backgroundColor.uiColor
        addSubview(desk360LogoImageView)
        desk360LogoImageView.centerInSuperview()
    }
}


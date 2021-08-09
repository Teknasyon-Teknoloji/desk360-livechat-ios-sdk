//
//  OrbitActivityIndicatorView.swift
//  ShowSomeProgress-iOS
//
//  Created by Alexander Kasimir on 06.08.19.
//  Copyright © 2019 ShowSomeProgress. All rights reserved.
//

import UIKit

class OrbitActivityIndicatorView: UIView, AnimatedActivityUIView {

    var timer: Timer?
    var frameRate: TimeInterval = 1 / 30
    var animationProgress: CGFloat = 0.0

    override func draw(_ rect: CGRect) {
        let colorParts = tintColor.components
        ActivityStyleKit.drawOrbitIndicator(
            frame: rect,
            resizing: .aspectFit,
            animationProgress: animationProgress,
            progressColorRed: colorParts.red,
            progressColorGreen: colorParts.green,
            progressColorBlue: colorParts.blue
        )
    }

}

class OrbitActivityIndicatorView2: UIView, AnimatedActivityUIView {

    var timer: Timer?
    var frameRate: TimeInterval = 1/30
    var animationProgress: CGFloat = 0.0

    override func draw(_ rect: CGRect) {
        let colorParts = tintColor.components
        ActivityStyleKit.drawOrbitIndicator2(
            frame: rect,
            resizing: .aspectFit,
            animationProgress: animationProgress,
            progressColorRed: colorParts.red,
            progressColorGreen: colorParts.green,
            progressColorBlue: colorParts.blue
        )
    }
}

class OrbitActivityIndicatorView3: UIView, AnimatedActivityUIView {

    var timer: Timer?
    var frameRate: TimeInterval = 1/30
    var animationProgress: CGFloat = 0.0

    override func draw(_ rect: CGRect) {
        let colorParts = tintColor.components
        ActivityStyleKit.drawOrbitIndicator3(
            frame: rect,
            resizing: .aspectFit,
            animationProgress: animationProgress,
            progressColorRed: colorParts.red,
            progressColorGreen: colorParts.green,
            progressColorBlue: colorParts.blue
        )
    }
}

class GearActivityIndicatorView: UIView, AnimatedActivityUIView {

    var timer: Timer?
    var frameRate: TimeInterval = 1/30
    var animationProgress: CGFloat = 0.0

    override func draw(_ rect: CGRect) {
        let colorParts = tintColor.components
        ActivityStyleKit.drawTripleGears(
            frame: rect,
            resizing: .aspectFit,
            animationProgress: animationProgress,
            progressColorRed: colorParts.red,
            progressColorGreen: colorParts.green,
            progressColorBlue: colorParts.blue
        )
    }
}

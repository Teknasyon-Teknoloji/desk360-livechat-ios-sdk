//
//  BadgeView.swift
//  LiveChat
//
//  Created by Ali Ammar Hilal on 28.07.2021.
//

import UIKit

enum BadgeDirection {
    case northEast
    case northWest
    case southEast
    case southWest
    case center
    
}

class BadgeLabel: UILabel {
    
    var padding: CGFloat = 8
    
    /// programmatic init
    ///   - Parameters:
    ///      - padding: The amount of padding from
    ///   the edges of the label to the text,
    ///   required to maintain circular shape
    ///   without clipping text
    init(backgroundColor: UIColor = .systemRed, text: String, padding: CGFloat = 8) {
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = backgroundColor
        self.text = text
        self.padding = padding
        
        commonInit()
        setConstraints()
        
    }
    
    /// constrain the height and width
    /// so the label forms a square,
    /// required to maintain circular shape
    private func setConstraints() {
        
        if bounds.size.width > bounds.size.height {
            heightAnchor.constraint(equalTo: widthAnchor).isActive = true
        } else {
            widthAnchor.constraint(equalTo: heightAnchor).isActive = true
        }
        
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        commonInit()
        
    }
    
    /// align text in the center of the label
    /// to avoid clipping and maintain visual
    /// consistency
    private func commonInit() {
        textAlignment = .center
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        tag = 1938010
        clipShape()
        
    }
    
    /// - set the label's cornerRadius to make a circle
    /// - mask and clip to bounds to preserve circular
    /// shape without allowing other elements to bleed
    /// outside of the bounds of the shape
    private func clipShape() {
        
        let cornerRadius = 0.5 * bounds.size.width
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        clipsToBounds = true
        
    }
    
    override func drawText(in rect: CGRect) {
        
        let insets = padWithInsets()
        super.drawText(in: rect.inset(by: insets))
        
    }
    
    /// add padding (half of class property to each side)
    private func padWithInsets() -> UIEdgeInsets {
        
        UIEdgeInsets(top: 0,
                     left: padding/2,
                     bottom: 0,
                     right: padding/2)
        
    }
    
    // increase content size to account for padding
    override var intrinsicContentSize: CGSize {
        
        var content = super.intrinsicContentSize
        content.width += padding
        return content
        
    }
    // MARK: - Badge Functionality -
    
    /// set the label's text with `value`
    func set(_ value: String) {
        text = value
    }
    
    /// remove the label from its superview
    func remove() {
        removeFromSuperview()
    }
    
    /// increment the current value by `num`
    @discardableResult func incrementIntValue(by num: Int) -> IntValueResult {
        
        switch convertTextToInt {
        
        case let .success(value):
            
            let totalValue = value.advanced(by: num)
            text = String(totalValue)
            return .success(totalValue)
            
        case let .failure(error):
            return .failure(error)
        }
    }
    
    private var convertTextToInt: IntValueResult {
        
        guard let text = text,
              let intVal = Int(text)
        else {
            let textValue = "\(text ?? "value")"
            let domain = "\(#function), \(textValue) cannot be converted to Int"
            let error = NSError(domain: domain, code: 0)
            return .failure(error)
        }
        return .success(intVal)
        
    }
}

extension BadgeLabel {
    
    enum IntValueResult {
        case success(Int)
        case failure(Error)
    }
}

extension UIView {
    
    /// add a new badge to the view
    /// - Parameters:
    ///   - direction: where the view's x/y boundaries will be anchored
    @discardableResult func setBadge(in direction: BadgeDirection, with text: String) -> BadgeLabel {
        subviews.filter({ $0.tag == 1938010 }).first?.removeFromSuperview()
        let badge = BadgeLabel(text: text)
        badge.font = FontFamily.Gotham.black.font(size: 8)
        badge.textColor = .white
        addSubview(badge)
        
        setBadgeConstraintsInSafeArea(for: badge, in: direction)
    
        return badge
    }
    
    /// set a badge's constraints in the given direction's boundaries
    /// - NOTE: requires iOS 11 or greater
    @available(iOS 11, *)
    private func setBadgeConstraintsInSafeArea(for badge: BadgeLabel, in direction: BadgeDirection) {
        
        switch direction {
            
        case .center:
            badge.centerInSuperview()
        case .northEast:
            let padding = -(badge.intrinsicContentSize.height / 2)
            badge.anchor(
                top: safeAreaLayoutGuide.topAnchor,
                trailing: safeAreaLayoutGuide.trailingAnchor,
                padding: .init(top: padding, left: 0, bottom: 0, right: padding)
            )
        case .northWest:
            NSLayoutConstraint.activate([
                badge.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                badge.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)
            ])
        case .southEast:
            NSLayoutConstraint.activate([
                badge.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                badge.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
            ])
        case .southWest:
            NSLayoutConstraint.activate([
                badge.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                badge.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)
            ])
            
        }
        
    }
}

fileprivate extension UIColor {
    static let majorelle = UIColor(red: 0.36, green: 0.40, blue: 0.91, alpha: 1.0)
    static let flamenco = UIColor(red: 0.92, green: 0.51, blue: 0.30, alpha: 1.0)
    static let wisteria = UIColor(red: 0.81, green: 0.64, blue: 0.83, alpha: 1.0)
    static let clamShall = UIColor(red: 0.84, green: 0.70, blue: 0.63, alpha: 1.0)
    static let lilac = UIColor(red: 1.00, green: 0.66, blue: 0.67, alpha: 1.0)
}

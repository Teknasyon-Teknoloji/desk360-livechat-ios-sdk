//
//  CustomTextField.swift
//  Desk360LiveChat
//
//  Created by Ali Ammar Hilal on 14.08.2021.
//

import Foundation
import UIKit

class CustomTextField: UITextField, UITextFieldDelegate {
    
    var textLimit = 0
    private var padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    init(padding: UIEdgeInsets) {
        self.padding = padding
        super.init(frame: .zero)
        delegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
    }
    
    func setPlaceHolderTextColor(_ color: UIColor) {
        guard let holder = placeholder, !holder.isEmpty else { return }
        attributedPlaceholder = NSAttributedString(string: holder, attributes: [.foregroundColor: color])
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shakeTextField() {
        let shake: CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let fromPoint: CGPoint = CGPoint(x: self.center.x - 5, y: self.center.y)
        let fromValue: NSValue = NSValue(cgPoint: fromPoint)
        
        let toPoint: CGPoint = CGPoint(x: self.center.x + 5, y: self.center.y)
        let toValue: NSValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        self.layer.add(shake, forKey: "position")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textLimit <= 0 { return true }
        
        guard let preText = textField.text as NSString?,
              preText.replacingCharacters(in: range, with: string).count <= textLimit else {
            return false
        }
        
        return true
    }
}

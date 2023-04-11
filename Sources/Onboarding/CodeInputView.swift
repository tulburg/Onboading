//
//  File.swift
//  
//
//  Created by Tolu Oluwagbemi on 11/04/2023.
//

import UIKit

@available(iOS 13.0, *)
public class CodeInputView: UITextField, UITextFieldDelegate {
    
    public var numel: Int = {
        return 4
    }()
    
    init(numel: Int, _ commit: ((_ text: String) -> Void)?) {
        self.numel = numel
        super.init(frame: .zero)
        font = .monospacedSystemFont(ofSize: 48, weight: .semibold)
        defaultTextAttributes.updateValue(33.0, forKey: NSAttributedString.Key.kern)
        let ps = NSMutableParagraphStyle()
        ps.firstLineHeadIndent = (54 - 48) + 6
        defaultTextAttributes.updateValue(ps, forKey: NSAttributedString.Key.paragraphStyle)
        textContentType = .oneTimeCode
        keyboardType = .numberPad
        self.commit = commit
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var appearance: Appearance?
    var commit: ((_ text: String) -> Void)?
    
    public struct Appearance {
        var cornerRadius: CGFloat?
        var fontSize: CGFloat?
        var backgroundColor: UIColor?
        var textColor: UIColor?
    }
    
    public func set(_ appearance: Appearance) {
        self.appearance = appearance
        self.font = .monospacedSystemFont(ofSize: appearance.fontSize ?? 48, weight: .semibold)
        self.textColor = appearance.textColor ?? .black
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let width = min((Int(frame.width) / numel), 54)
        for i in 0..<numel {
            let shapeLayer = CAShapeLayer()
            let path = UIBezierPath(roundedRect: CGRect(x: i * (width + 8), y: 0, width: width, height: Int((appearance?.fontSize ?? CGFloat(width))) + 16), cornerRadius: appearance?.cornerRadius ?? 8)
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = (appearance?.backgroundColor ?? UIColor.separatorLight).cgColor
            layer.insertSublayer(shapeLayer, at: 0)
        }
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string != "" {
            return text!.count < numel
        }
        return true
    }
    
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text?.count == numel {
            commit?(textField.text!)
        }
    }
}

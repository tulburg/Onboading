//
//  File.swift
//  
//
//  Created by Tolu Oluwagbemi on 20/03/2023.
//

import UIKit

@available(iOS 13.0, *)
extension UIColor {
    convenience init(hex: Int) {
        self.init(red: CGFloat((hex >> 16) & 0xff) / 255.0, green: CGFloat((hex >> 8) & 0xff) / 255.0, blue: CGFloat(hex & 0xff) / 255.0, alpha: 1)
    }
    static func create(_ light: Int, dark: Int) -> UIColor {
        return UIColor(dynamicProvider: { trait in
            return trait.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
    
    static let background = create(0xFFFFFF, dark: 0x101010)
    static let blackWhite = create(0x000000, dark: 0xFFFFFF)
    static let separatorLight = UIColor.create(0xF0F0F0, dark: 0x1F1F1F)
    static let accent = UIColor(hex: 0x784AC2)
    static let text = create(0x494949, dark: 0xc0c0c0)
    static let primary = UIColor(hex: 0x2E466B)
    static let titleText = create(0x262626, dark: 0xcdcdcd)
    static let darkBackground = create(0xf5f5f5, dark: 0x252525)
}

extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func resize(_ size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        
        self.draw(in: CGRect(x:0, y:0, width:size.width, height:size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return newImage
    }
}

extension UILabel {
    convenience init(_ text: String, _ color: UIColor?, _ font: UIFont?) {
        self.init()
        self.text = text
        self.font = UIFont.systemFont(ofSize: 12)
        if color != nil {
            self.textColor = color!
        }
        if font != nil {
            self.font = font
        }
    }
}

extension Date {
    func string(with format: String) -> String{
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }
}


extension UIView {
    
    func addConstraints(format: String, views: UIView...) {
        addConstraints(format: format, views: views)
    }
    
    func addConstraints(format: String, views: [UIView]) {
        var viewDict = [String: Any]()
        for(index, view) in views.enumerated() {
            view.translatesAutoresizingMaskIntoConstraints = false
            let key = "v\(index)"
            viewDict[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewDict))
    }
    
    func constrain(type: ConstraintType, _ views: UIView..., margin: Float = 0) {
        switch type {
        case .horizontalFill:
            for view in views {
                addConstraints(format: "H:|-\(margin)-[v0]-\(margin)-|", views: view)
            }
        case .verticalFill:
            for view in views {
                addConstraints(format: "V:|-\(margin)-[v0]-\(margin)-|", views: view)
            }
        case .verticalCenter:
            for view in views {
                addConstraints(format: "V:|-(>=\(margin))-[v0]-(>=\(margin))-|", views: view)
                view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            }
        case .horizontalCenter:
            for view in views {
                addConstraints(format: "H:|-(>=\(margin))-[v0]-(>=\(margin))-|", views: view)
                view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            }
        }
    }
    
    func add() -> ConstrainChain {
        return ConstrainChain(self)
    }
    
    func addSubviews(views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
    
    func debugLines(color: UIColor?) {
        self.layer.borderWidth = 1
        self.layer.borderColor = color?.cgColor
    }
    func debugLines() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.red.cgColor
    }
    
    class ConstrainChain {
        var chain: String = ""
        var host: UIView!
        var viewIndex: Int = 0
        var subviews: [UIView] = []
        init(_ host: UIView) {
            self.host = host
        }
        
        func vertical(_ startMargin: CGFloat) -> ConstrainChain {
            chain += "V:|-(\(startMargin))-"
            return self
        }
        
        func vertical(_ startMargin: String) -> ConstrainChain {
            chain += "V:|-(\(startMargin))-"
            return self
        }
        func horizontal(_ startMargin: CGFloat) -> ConstrainChain {
            chain += "H:|-(\(startMargin))-"
            return self
        }
        
        func horizontal(_ startMargin: String) -> ConstrainChain {
            chain += "H:|-(\(startMargin))-"
            return self
        }
        
        func view(_ subView: UIView) -> ConstrainChain {
            if subviews.firstIndex(of: subView) == nil {
                host.addSubview(subView)
                subviews.append(subView)
            }
            chain += "[v\(viewIndex)]-"
            viewIndex += 1
            return self
        }
        func view(_ subView: UIView, _ size: CGFloat) -> ConstrainChain {
            if subviews.firstIndex(of: subView) == nil {
                host.addSubview(subView)
                subviews.append(subView)
            }
            chain += "[v\(viewIndex)(\(size))]-"
            viewIndex += 1
            return self
        }
        func view(_ subView: UIView, _ size: String) -> ConstrainChain {
            if subviews.firstIndex(of: subView) == nil {
                host.addSubview(subView)
                subviews.append(subView)
            }
            chain += "[v\(viewIndex)(\(size))]-"
            viewIndex += 1
            return self
        }
        func gap(_ margin: CGFloat) -> ConstrainChain {
            chain += "(\(margin))-"
            return self
        }
        func gap(_ margin: String) -> ConstrainChain {
            chain += "(\(margin))-"
            return self
        }
        
        func end(_ margin: CGFloat) {
            chain += "(\(margin))-|"
            host.addConstraints(format: chain, views: subviews)
        }
        func end(_ margin: String) {
            chain += "(\(margin))-|"
            host.addConstraints(format: chain, views: subviews)
        }
    }
    
    enum ConstraintType {
        case horizontalFill
        case verticalFill
        case horizontalCenter
        case verticalCenter
    }
}

extension UITextView {
    
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    @objc public func textViewDidChange(_ sender: NSNotification) {
        guard let textView = sender.object as? UITextView else { return }
        if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
    
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainerInset.left + textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top
            let labelWidth = max(self.frame.width, 120)
            let labelHeight = placeholderLabel.frame.height
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        placeholderLabel.isHidden = !self.text.isEmpty
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange),
                                               name: NSNotification.Name("UITextViewTextDidChangeNotification"),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange), name: NSNotification.Name("UITextViewTextDidChangeSelection"), object: nil)
    }
}

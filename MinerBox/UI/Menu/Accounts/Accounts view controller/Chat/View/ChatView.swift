//
//  ChatView.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 01.04.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit
import WebKit

protocol ChatViewDelegate {
    func touchesBegan(_ touches: Set<UITouch>)
    func touchesEnded()
    func mailSelected()
}

class ChatView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var webView: UIView!
    @IBOutlet weak var upDownImageView: UIImageView!
    @IBOutlet weak var errorTextView: UITextView!
    
    var delegate: ChatViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ChatView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        initialSetup()
        imageViewSetup()
        errorSetup()
    }
    
    private func initialSetup() {
        self.isHidden = true
        self.backgroundColor = .clear
        headerView.backgroundColor = .barSelectedItem
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.barSelectedItem.cgColor
        self.layer.cornerRadius = 10
    }
    
    private func imageViewSetup() {
        let image = UIImage(named: "arrowUpDown")?.withRenderingMode(.alwaysTemplate)
        upDownImageView.image = image
        upDownImageView.tintColor = .white
    }
    
    private func errorSetup() {
        let mail = MailManager.shared.supportMail
        let title = "Sorry, Live chat service is temporarily unavailable, \nPlase use email support insted \n\(mail)"
        errorTextView.textAlignment = .center
        errorTextView.text = title
        
        // Create an attributed string
        let myString = NSMutableAttributedString(attributedString: errorTextView.attributedText!)
        
        // Set an attribute on part of the string
        let location = title.count - mail.count
        let myRange = NSRange(location: location, length: mail.count) // range of mail
        let myCustomAttributes = [
            NSAttributedString.Key.myAttributeName: mail,
            NSAttributedString.Key.foregroundColor: UIColor.barSelectedItem,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ] as [NSAttributedString.Key : Any]
        myString.addAttributes(myCustomAttributes, range: myRange)
        errorTextView.attributedText = myString
        
        // Add tap gesture recognizer to Text View
        let tap = UITapGestureRecognizer(target: self, action: #selector(myMethodToHandleTap(_:)))
        errorTextView.addGestureRecognizer(tap)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.touchesBegan(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.touchesEnded()
    }
    
    @objc func myMethodToHandleTap(_ sender: UITapGestureRecognizer) {
        let myTextView = sender.view as! UITextView
        let layoutManager = myTextView.layoutManager
        
        // location of tap in myTextView coordinates and taking the inset into account
        var location = sender.location(in: myTextView)
        location.x -= myTextView.textContainerInset.left;
        location.y -= myTextView.textContainerInset.top;
        
        // character index at tap location
        let characterIndex = layoutManager.characterIndex(for: location, in: myTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // if index is valid then do something.
        if characterIndex < myTextView.textStorage.length {
            
            // print the character index
            print("character index: \(characterIndex)")
            
            // print the character at the index
            let myRange = NSRange(location: characterIndex, length: 1)
            let substring = (myTextView.attributedText.string as NSString).substring(with: myRange)
            print("character at index: \(substring)")
            
            // check if the tap location has a certain attribute
            let attributeName = NSAttributedString.Key.myAttributeName
            let attributeValue = myTextView.attributedText?.attribute(attributeName, at: characterIndex, effectiveRange: nil)
            if let _ = attributeValue {
                //                    print("You tapped on \(attributeName.rawValue) and the value is: \(value)")
                delegate?.mailSelected()
            }
        }
    }
    
}

//
//  MB+UITextField.swift
//  MinerBox
//
//  Created by Haykaz Melikyan on 7/4/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import UIKit

extension UITextField {
    func setBottomBorderWarning() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.red.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }

    func isError() {
        let revert = true
        let baseColor = UIColor.red.cgColor
        let shakes: Float = 3.0
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "shadowColor")
        animation.fromValue = baseColor
        animation.toValue = UIColor.red.cgColor
        animation.duration = 2
        if revert { animation.autoreverses = true }
        self.layer.add(animation, forKey: "")

        let shake: CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.07
        shake.repeatCount = shakes
        if revert { shake.autoreverses = true }
        shake.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(shake, forKey: "position")
    }
    
    func allowOnlyNumbersForConverter(string: String) -> Bool {
        let testDouble = 0.7
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        
        let fractionSymbol = testDouble.getFormatedString().components(separatedBy: CharacterSet.decimalDigits).joined()
        
        if self.text!.count == 0 && (string == "0" || string == "." || string == ",") {
            self.text = "0" + fractionSymbol
            return false
        }
        
//        if string.toInt() == nil && string != "" {
//            if string == "." || string == "," {
//                if !self.text!.contains(fractionSymbol) {
//                    self.text = self.text! + fractionSymbol
//                }
//            }
//            return false
//        }
        
        if self.text == "0." || self.text == "0," {
            if string == "" {
                self.text = ""
            }
            if string == "." || string == "," {
                return false
            }
        }
        return true
    }
    
    func allowOnlyNumbers(string: String) -> Bool {
        if self.text!.count == 0 && (string == "0" || string == ".") {
            self.text = "0."
            return false
        }
        
        if Int(string) == nil && string != "" {
            if string == "." {
                if self.text!.contains(".") {
                    return false
                } else {
                    return true
                }
            } else {
                return false
            }
        }
        
        
        if self.text == "0." {
            if string == "" {
                self.text = ""
            }
            if string == "." {
                return false
            }
        }
        return true
    }
    
    func allowOnlyInt(string: String) -> Bool {
        if self.text!.count == 0 && string == "0" {
            return false
        }
        
        if Int(string) == nil && string != "" {
            return false
        }
        
        return true
    }
    
    func getFormatedText() {
        guard var text = self.text else { return }
        
        configText(text: &text)
    }
    
    private func configText(text: inout String) {
        let testDouble = 0.7
        let fractionSymbol = testDouble.getFormatedStringForTextField().components(separatedBy: CharacterSet.decimalDigits).joined()
        
        var characters = ""


        
        let char = text.suffix(1)
        
        //fix 30 for big number
        guard text.count > 1 && text.count < 30 && Int(char) != nil else { return }
        
      //  text.removeLast()
        
        text.filterDigits()
        
        if let int = text.toInt(), !text.contains(fractionSymbol) {
            let intStr = String(int) // + char
            
            if let int = intStr.toInt() {
                self.text = int.getFormatedString()
            } else if let double = Double(intStr) {
                self.text = double.getFormatedStringForTextField()
            }
        } else if let double = Double(text) {
            let doubleStr = String(double) // + char
            if let double = Double(doubleStr) {
                for index in 0...text.count {  // when String type Convert to Double last 0 chracter was removed
                    let sinvol = text.suffix(index + 1 ).prefix(1)
                    guard sinvol == "0" else {
                        return
                    }
                    characters += "0"
                }
                self.text = double.getFormatedStringForTextField(char: String(characters))
            }
        }
    }    
}

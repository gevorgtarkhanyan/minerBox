//
//  String extension.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/30/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

extension String {
    
    static let numberFormatter = NumberFormatter()
    
    func showPoolId(idFormat: String) -> String {
        
        var str = self
        var isUrl = false
        
        if(idFormat != "") {
            let keyName = idFormat.prefix(idFormat.count-1)
            
//            guard let url  = URL(string: self) else { return self }
//            guard URLComponents(url: url, resolvingAgainstBaseURL: false) != nil else { return self }
            
            if let url = URLComponents(string: self) {
                if let param = url.queryItems?.first(where: { $0.name == keyName })?.value {
                    str = param
                    isUrl = true
                }
            }
        }
        
        let length = (str.count <= 20) ? Int(str.count / 3) : 10
        
        let str1 = str.prefix(length)
        let str2 = str.suffix(length)
        
        if isUrl {
            return String("..." + str1 + "..." + str2 + "...")
        }
        else {
            return String(str1 + "..." + str2)
        }
    }
    
    func containPoolSpecificSpecialCharacters(filter: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "[^" + filter + "]")
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
    
    func containSpecialCharacters(characters: String) -> Bool {
        let characterset = CharacterSet(charactersIn: characters)
        return rangeOfCharacter(from: characterset.inverted) != nil
    }
    func containSpecialCharacters() -> Bool {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._@")
        return rangeOfCharacter(from: characterset.inverted) != nil
    }
    
    func containSpecialCharactersWithSpace() -> Bool {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._@ ")
        return rangeOfCharacter(from: characterset.inverted) != nil
    }
    
    func toDouble() -> Double? {
        let strings = self.components(separatedBy: " ")
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        for component in strings {
//            component.filterDigits()
            if let num = formatter.number(from: component)?.doubleValue {
                return num
            }
        }
        return nil
    }
    
    mutating func removeOptional() {
        if contains("Optional") {
            removeFirst(8)
            self = filter { !"(\"\")".contains($0) }
        }
        if self == "nil" || self == "-1.0" {
            self = ""
        }
    }
    
    func toDoubleForWorker() -> Double? {
        if contains("(") {
            return components(separatedBy: "(").first?.toDouble()
        } else if contains("%") {
            return components(separatedBy: "%").first?.toDouble()
        }
        return toDouble()
    }
    
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
    
    mutating func filterDigits() {
        let testDouble = 0.7
        let fractionSymbol = testDouble.getFormatedString().components(separatedBy: CharacterSet.decimalDigits).joined()
        
        var d = self
        d.removeAll { "0123456789\(fractionSymbol)".contains($0) }
        self.removeAll { d.contains($0) }
    }
    
    func toInt() -> Int? {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        
        return nf.number(from: self) as? Int
        
    }
    
    func toUInt64() -> UInt64? {
         return UInt64(self)
    }
    
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    //MARK: - Replace
    func replace(xxx: String, yyy: String) -> String {
        var text = ""
        text = replacingOccurrences(of: "xxx", with: xxx)
        text = text.replacingOccurrences(of: "yyy", with: yyy)
        return text
    }
    
    // MARK: -- Html support code
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    
    func htmlAttributed(using font: UIFont) -> NSAttributedString? {
         do {
             let htmlCSSString = "<style>" +
                 "html *" +
                 "{" +
                 "font-size: \(font.pointSize)pt !important;" +
                 "font-family: \(font.familyName), Helvetica !important;" +
                 "}</style> \(self)"

             guard let data = htmlCSSString.data(using: String.Encoding.utf8) else {
                 return nil
             }

             return try NSAttributedString(data: data,
                                           options: [.documentType: NSAttributedString.DocumentType.html,
                                                     .characterEncoding: String.Encoding.utf8.rawValue],
                                           documentAttributes: nil)
         } catch {
             print("error: ", error)
             return nil
         }
     }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    func textHashrateToDouble() -> Double { // For Sorting Mode
        if var count = self.toDouble() {
            
            if self.contains("K")  {
                count *= 1_000
            } else if self.contains("M")  {
                count *= 1_000_000
            } else if self.contains("G")  {
                count *= 1_000_000_000
            } else if self.contains("T")  {
                count *= 1_000_000_000_000
            } else if self.contains("P") {
                count *= 1_000_000_000_000_000
            } else if self.contains("E") {
                count *= 1_000_000_000_000_000_000
            } else if self.contains("Z") {
                count *= 1_000_000_000_000_000_000_000
            }
            return count
        }
        return Double()
    }
    
    func getImageWithURL() -> UIImage {
        do {
            let data = try Data(contentsOf: URL(string: self)!)
            let imag: UIImage = UIImage(data: data) ?? UIImage()
            return imag
        } catch {
            print("URL is Valid")
            return UIImage()
        }
    }
    
    //MARK: - URL Encod
    func urlEncoded(denying deniedCharacters: CharacterSet = .urlDenied) -> String {
        return addingPercentEncoding(withAllowedCharacters: deniedCharacters.inverted()) ?? self
    }
    
    func convertForLocalize() -> String {
        let per = " (%)"
        switch self {
        case "rewards":             return "account_rewards"
        case "orphan":              return "orphaned"
        case "timestamp":           return "time"
        case "txHash":              return "tx"
        case "blockNumber":         return "blocks"
        case "cfms":                return "confirmations"
        case "shareDifficulty":     return "difficulty"
                
        case "luckPer":             return "luck".localized() + per
        case "txFeePer":            return "txFee".localized() + per
        case "networkFeePer":       return "networkFee".localized() + per
        case "sharePer":            return "shares".localized() + per
        default:                    return self
        }
    }
}

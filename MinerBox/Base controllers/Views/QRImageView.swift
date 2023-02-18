//
//  QRImageView.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 24.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import Foundation
import UIKit


class QRImageView: UIImageView {
    // MARK: - Properties
    fileprivate var qrString = ""
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


// MARK: - Set data
extension QRImageView {
    
    public func setValueForQR(_ value: String) {
        qrString = value
        generateQRImage()
    }
    
    fileprivate func generateQRImage() {
        
        let data = qrString.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        guard let qrCodeImage = filter?.outputImage else { return }
        
        let scaleX = self.frame.size.width / qrCodeImage.extent.size.width
        let scaleY = self.frame.size.height / qrCodeImage.extent.size.height
        let transformedImage = qrCodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        if let colorImgae = updateColor(image: transformedImage) {
            self.image =  UIImage(ciImage: colorImgae)
        }
    }
    
    fileprivate func updateColor(image: CIImage) -> CIImage? {
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        
        colorFilter.setValue(image, forKey: kCIInputImageKey)
        colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor0")
        colorFilter.setValue(CIColor(red: 30/255, green: 155/255, blue: 152/255, alpha: 0), forKey: "inputColor1")
        return colorFilter.outputImage
    }
}



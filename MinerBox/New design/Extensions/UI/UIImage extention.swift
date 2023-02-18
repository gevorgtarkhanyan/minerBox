//
//  UIImage extention.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 28.12.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

extension UIImage {
    func createLocalURL(name: String) -> URL? {
        guard let data = self.pngData() else {
            debugPrint("Coule not get UIImagePNGRepresentation Data for photo")
            return nil
        }

        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else { return nil }

        let localUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(name)

        do {
            try data.write(to: localUrl)
        } catch let error {
            debugPrint("Failed to write to URL")
            debugPrint(error)
        }
        return localUrl
    }
    
//    func rotate(radians: CGFloat) -> UIImage {
//        let rotatedSize = CGRect(origin: .zero, size: size)
//            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
//            .integral.size
//        UIGraphicsBeginImageContext(rotatedSize)
//        if let context = UIGraphicsGetCurrentContext() {
//            let origin = CGPoint(x: rotatedSize.width / 2.0,
//                                 y: rotatedSize.height / 2.0)
//            context.translateBy(x: origin.x, y: origin.y)
//            context.rotate(by: radians)
//            draw(in: CGRect(x: -origin.y, y: -origin.x,
//                            width: size.width, height: size.height))
//            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//
//            return rotatedImage ?? self
//        }
//
//        return self
//    }
}
extension UIImage {

    @available(iOS 10.0, *)
    func scaled(toWidth width: CGFloat) -> UIImage? {

        guard width > 0.0, self.size.width > 0.0 else {
            return nil
        }

        return self.redrawnImage(with: self.size.scaled(toWidth: width))
    }

    @available(iOS 10.0, *)
    func scaled(toHeight height: CGFloat) -> UIImage? {

        guard height > 0.0, self.size.height > 0.0 else {
            return nil
        }

        return self.redrawnImage(with: self.size.scaled(toHeight: height))
    }

    @available(iOS 10.0, *)
    private func redrawnImage(with size: CGSize) -> UIImage {

        UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: .init(origin: .zero, size: size))
        }
    }
}

extension CGSize {

    func scaled(toWidth width: CGFloat) -> CGSize {
        CGSize(width: width, height: (self.height / self.width) * width)
    }

    func scaled(toHeight height: CGFloat) -> CGSize {
        CGSize(width: (self.width / self.height) * height, height: height)
    }
}

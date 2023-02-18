//
//  ShareManager.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 12.11.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//


import UIKit
import xlsxwriter

class ShareManager {
    
    private static var stackSpaces: [CGFloat] = []
    
    static func share(_ vc: UIViewController,
                      drawViews: [UIView] = [],
                      spaces: [CGFloat] = [],
                      removedView: UIView? = nil,
                      shareType: ShareType = .png,
                      data: [Any] = [],
                      fileName: String = "fileName")  {
        
        stackSpaces = spaces
        removedView?.alpha = 0
        var sharedItem: Any? = nil
        switch shareType {
        case .png:
            sharedItem = getPngUrl(vc, views: drawViews, fileName: fileName)
        case .xlsx:
            sharedItem = generateExcelFile(data: data, fileName: fileName)
        }
        
        guard let item = sharedItem else { return }
                
        presentActivity(vc, spaces: spaces, removedView: removedView, fileName: fileName , item: item )
    }
    
    static func shareText(_ vc: UIViewController,
                      text: String? = nil,
                      fileName: String = "fileName")  {
        
        var sharedItem: Any? = nil
        sharedItem = text
        
        guard let item = sharedItem else { return }
        
        presentActivity(vc, item: item )

    }
    
    private static func presentActivity(_ vc: UIViewController,
                         spaces: [CGFloat] = [],
                         removedView: UIView? = nil,
                         fileName: String = "fileName",
                         item: Any ) {
        
        let activityViewController = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = vc.view
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            if let item = item as? URL {
                try? FileManager.default.removeItem(atPath: item.path)
            }
            removedView?.alpha = 1
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            let center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height)
            activityViewController.popoverPresentationController?.sourceRect.origin = center
        }
        vc.present(activityViewController, animated: true, completion: nil)
    }
    
    //MARK: - PNG
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private class func getPngUrl(_ vc: UIViewController, views: [UIView] = [], fileName: String) -> URL? {
        guard let sendedImage = views.isEmpty ? getScreenImage(vc) : getContentImage(vc, views: views),
              let data = sendedImage.pngData()  else { return nil }
        
        let fileURL = getDocumentsDirectory().appendingPathComponent("\(fileName.localized()).png")
            try? data.write(to: fileURL)
        
        return fileURL
    }
    
    private class func getScreenImage(_ vc: UIViewController) -> UIImage? {
        guard let view = vc.view else { return nil }
        
        let screenImage = view.takeScreenshot()
        let mainImageView = UIImageView(image: screenImage)
        
        let logoContentView = UIView(frame: CGRect(x: 0, y: mainImageView.frame.height, width: view.frame.width, height: 40))
        let logoImageView = UIImageView(frame: CGRect(x: logoContentView.frame.maxX - 50, y: 0, width: 30, height: 30))
        let titleLabel = BaseLabel(frame: CGRect(x: logoImageView.frame.origin.x - 85, y: logoImageView.frame.origin.y, width: 100, height: 30))
        
        logoImageView.image = UIImage(named: "logo")
        titleLabel.text = "Miner Box"
        titleLabel.textColor = .cellTrailingFirst
        logoContentView.addSubview(logoImageView)
        logoContentView.addSubview(titleLabel)
        
        mainImageView.addSubview(logoContentView)
        logoContentView.backgroundColor = view.backgroundColor
        
        var size = view.bounds.size
        size.height += 40
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        mainImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let sendedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return sendedImage
    }
    
    private class func getContentImage(_ vc: UIViewController, views: [UIView]) -> UIImage? {
        guard let view = vc.view else { return nil }
        
        ///logo
        let logoContentView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        let logoImageView = UIImageView(frame: CGRect(x: logoContentView.frame.maxX - 50, y: 0, width: 30, height: 30))
        let titleLabel = BaseLabel(frame: CGRect(x: logoImageView.frame.origin.x - 85, y: logoImageView.frame.origin.y, width: 100, height: 30))
        
        logoImageView.image = UIImage(named: "logo")
        titleLabel.text = "Miner Box"
        titleLabel.textColor = .cellTrailingFirst
        logoContentView.addSubview(logoImageView)
        logoContentView.addSubview(titleLabel)
        logoContentView.backgroundColor = view.backgroundColor
        
        ///content
        let screenShots = views.map { UIImageView(image: $0.takeScreenshot()).inParentView(view.backgroundColor) }
        let heights = screenShots.map { $0.bounds.height }
        let allSpace = stackSpaces.isEmpty ? CGFloat(screenShots.count * 16) + 16 : stackSpaces.reduce(0, +) + 16
        let totalHeight = heights.reduce(0, +) + logoContentView.bounds.height + allSpace

        let stackView = UIStackView(arrangedSubviews: screenShots)
        stackView.addArrangedSubview(logoContentView)
        stackView.bounds = CGRect(x: 0, y: 0, width: view.bounds.width, height: totalHeight)
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.insertArrangedSubview(UIView(frame: .zero), at: 0)
        stackView.addBackground(color: view.backgroundColor)
        
        for (index, space) in stackSpaces.enumerated() {
            stackView.addCustomSpacing(space, after: stackView.arrangedSubviews[index])
        }
        
        return stackView.takeScreenshot()
    }
    
    //MARK: - XLSX
    private class func generateExcelFile(data: [Any], fileName: String) -> URL {
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create:false)
        let fileURL = documentDirectory.appendingPathComponent("\(fileName.localized()).xlsx")
        
        let workbook = workbook_new((fileURL.absoluteString.dropFirst(6) as NSString).fileSystemRepresentation)
        let worksheet = workbook_add_worksheet(workbook, nil)
        
        let excelData = getExelData(data)
        
        for (column, columnValues) in excelData.enumerated() {
            for (row, value) in columnValues.enumerated() {
                let row = UInt32(row)
                let column = UInt16(column)
                worksheet_write_string(worksheet, row, column, value, nil)
            }
        }
        
        if excelData.count > 1 {
            for (index, value) in excelData.enumerated() {
                let labelWidth = Double(value[0].count) + 5
                worksheet_set_column(worksheet, UInt16(index), UInt16(index), labelWidth, nil)
            }
        }
         
        workbook_close(workbook)
        
        return fileURL
    }
    
    private class func getExelData(_ data: [Any]) -> [[String]] {
        var exelData = [[String]]()
        
        guard let first = data.first else { return [] }
        
        for (mirrorIndex, mirrorLabel) in Mirror(reflecting: first).children.compactMap({ $0.label }).enumerated() {
            let label = mirrorLabel.convertForLocalize().localized()
            var subArr: [String] = [label]
            var columnWidth = label.count
            
            for value in data {
                let mValues = Mirror(reflecting: value).children.map({ $0.value })
                guard mValues.count > mirrorIndex else { return [] }
                
                let mirorValue = mValues[mirrorIndex]
                var mValue = "\(mirorValue)"
                mValue.removeOptional()
                columnWidth = max(columnWidth, mValue.count)
                subArr.append(mValue)
            }
            
            if columnWidth > subArr[0].count {
                let deff = columnWidth - subArr[0].count
                let space = String(repeating: " ", count: deff)
                subArr[0] += space
            }
            
            if let last = subArr.last {
                switch last {
                case "-1.0":
                    if (subArr.contains { $0 != "-1.0" && $0 != label }) {
                        exelData.append(subArr)
                    }
                case "-1":
                    if (subArr.contains { $0 != "-1" && $0 != label }) {
                        exelData.append(subArr)
                    }
                case "0.0":
                    if (subArr.contains { $0 != "0.0" && $0 != label }) {
                        exelData.append(subArr)
                    }
                case "":
                    if (subArr.contains { $0 != "" && $0 != label }) {
                        exelData.append(subArr)
                    }
                default:
                    exelData.append(subArr)
                }
            }
        }
        
        return exelData
    }
    
}

//MARK: - Helper
public enum ShareType: String, CaseIterable {
    case png
    case xlsx
    
    init(_ index: Int) {
        self = index == 0 ? .png : .xlsx
    }
}

//
//  UIView extension.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/10/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

extension UIView {
    enum Radius {
        case half
    }
    
    public var containsSearchBar: Bool {
        return subviews.contains(where: { $0 is UISearchBar })
    }
    
    public var containsTextField: Bool {
        return getAllTextFields(fromView: self).count != 0
    }
    
    //usage vc view
    var isLandscape: Bool {
        return bounds.width > bounds.height
    }
    
    private func getAllTextFields(fromView view: UIView)-> [UITextField] {
        return view.subviews.compactMap { (view) -> [UITextField]? in
            if view is UISearchBar {
                return nil
            } else if view is UITextField {
                return [(view as! UITextField)]
            } else {
                return getAllTextFields(fromView: view)
            }
        }.flatMap({$0})
    }
    
    func roundCorners(_ corners: CACornerMask = [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: CGFloat) {
        if #available(iOS 11, *) {
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = corners
        } 
    }
    
    func cornerRadius(radius: CGFloat) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = radius
    }
    
    func cornerRadius(radiusType: Radius) {
        switch radiusType {
        case .half:
            cornerRadius(radius: self.frame.height / 2)
        }
    }
    
    func addEqualRatioConstraint() {
        NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0).isActive = true
    }
    
    func changeConstraintMultiplier(_ constraint: inout NSLayoutConstraint, _ newMultiplier: CGFloat) {
        let newConstraint = constraint.constraintWithMultiplier(newMultiplier)
        self.removeConstraint(constraint)
        self.addConstraint(newConstraint)
        self.layoutIfNeeded()
        constraint = newConstraint
    }
}

//MARK: - Draw
extension UIView {
    func capture() -> UIImage? {
        var image: UIImage?
        if #available(iOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat()
            format.opaque = false
            let renderer = UIGraphicsImageRenderer(size: frame.size, format: format)
            image = renderer.image { context in
                drawHierarchy(in: frame, afterScreenUpdates: true)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(frame.size, isOpaque, UIScreen.main.scale)
            drawHierarchy(in: frame, afterScreenUpdates: true)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }

        return image
    }
    
    func snapshotViewHierarchy() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let copied = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return copied
    }
    
    func contentScreenshot(_ color: UIColor? = nil) -> UIImage? {
        let size = bounds.size
        let oldColor = backgroundColor
        backgroundColor = color ?? backgroundColor
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let sendedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        backgroundColor = oldColor
        return sendedImage
    }
    
    func takeScreenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func inParentView(_ bcolor: UIColor? = .clear) -> UIView {
        let parentView = UIView(frame: self.bounds)
        parentView.backgroundColor = bcolor
        parentView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
        topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        parentView.layoutIfNeeded()
        return parentView
    }
    
    func animateSnapshotView() {
        let overlayView = UIScreen.main.snapshotView(afterScreenUpdates: false)
        addSubview(overlayView)
        
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            overlayView.alpha = 0
        }) { (_) in
            overlayView.removeFromSuperview()
        }
    }
    
    func animateWithShake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))

        self.layer.add(animation, forKey: "position")
    }
}

//MARK: - Point
extension UIView {
    public var globalPoint: CGPoint? {
        return self.superview?.convert(self.frame.origin, to: nil)
    }
        
    public var globalFrame: CGRect? {
        return self.superview?.convert(self.frame, to: nil)
    }

    public var alertPoint: CGPoint? {
        guard let globalFrame = globalFrame, let globalPoint = globalPoint else { return nil }
        let x = globalPoint.x + globalFrame.width / 2
        let y = globalPoint.y + globalFrame.height
        
        return CGPoint(x: x, y: y)
    }
}

//MARK: - Alert Cancel Background
extension UIView {
    private struct AssociatedKey {
        static var subviewsBackgroundColor = "subviewsBackgroundColor"
    }

    @objc dynamic var subviewsBackgroundColor: UIColor? {
        get {
          return objc_getAssociatedObject(self, &AssociatedKey.subviewsBackgroundColor) as? UIColor
        }

        set {
          objc_setAssociatedObject(self,
                                   &AssociatedKey.subviewsBackgroundColor,
                                   newValue,
                                   .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
          subviews.forEach { $0.backgroundColor = newValue }
        }
    }
    
}

extension CGAffineTransform {
    var scale: CGFloat {
        return CGFloat(sqrt(Double(a * a + c * c)))
    }
}


//MARK: - Seperator
extension UIView {
    func addSeparatorView(from firstItem: UIView? = nil, to secondItem: UIView? = nil, color: UIColor? = nil) {
        let separatorView = UIView(frame: .zero)
        separatorView.backgroundColor = color ?? .separator
        addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        if firstItem != nil, secondItem != nil {
            separatorView.rightAnchor.constraint(equalTo: secondItem!.rightAnchor).isActive = true
            separatorView.leftAnchor.constraint(equalTo: firstItem!.leftAnchor).isActive = true
        } else {
            separatorView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            separatorView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        }
        
        separatorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: Constants.separatorHeight).isActive = true
    }
}

//MARK: - CornerRadius
@IBDesignable extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            
            // If masksToBounds is true, subviews will be
            // clipped to the rounded corners.
            layer.masksToBounds = (newValue > 0)
        }
    }
}

//MARK: - RotateOjbacts
@IBDesignable
class DesignableLabel: UILabel {
}

extension UIView {
    @IBInspectable
    var rotation: Int {
        get {
            return 0
        } set {
            let radians = ((CGFloat.pi) * CGFloat(newValue) / CGFloat(180.0))
            self.transform = CGAffineTransform(rotationAngle: radians)
        }
    }
}

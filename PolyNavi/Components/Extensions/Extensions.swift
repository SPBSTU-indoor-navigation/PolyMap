//
//  Extensions.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.02.2022.
//

import UIKit

extension UIScrollView {
    
    var topOffset: CGFloat {
        return safeAreaInsets.top
    }
    
    var topContentOffset: CGPoint {
        get {
            return CGPoint(x: contentOffset.x, y: contentOffset.y + topOffset)
        }
        
        set {
            contentOffset = CGPoint(x: newValue.x, y: newValue.y - topOffset)
        }
    }
}


extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}

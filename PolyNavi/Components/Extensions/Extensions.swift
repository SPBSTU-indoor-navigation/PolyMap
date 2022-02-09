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

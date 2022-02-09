//
//  BottomSheetPage.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.02.2022.
//

import UIKit

class BottomSheetPage: UIViewController {
    var delegate: BottomSheetPageDelegate?
    
    func onStateChange(verticalSize: BottomSheetViewController.VerticalSize) { }
    func onStateChange(horizontalSize: BottomSheetViewController.HorizontalSize) { }
}

class BluredBackgroundBottomSheetPage: BottomSheetPage {
    lazy var background: UIView = {
        $0.frame = view.frame
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        $0.layer.cornerRadius = 11
        $0.clipsToBounds = true
        
        let blur: UIVisualEffectView = {
            $0.frame = view.bounds
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return $0
        }(UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial)))
        
        $0.insertSubview(blur, at: 0)
        return $0
    
    }(UIView())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(background)
        view.backgroundColor = .clear
        
        view.layer.shadowRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowOpacity = BottomSheetViewController.Constants.shadowOpacity
    }
    
    override func onStateChange(horizontalSize: BottomSheetViewController.HorizontalSize) {
        super.onStateChange(horizontalSize: horizontalSize)
        background.layer.maskedCorners = horizontalSize == .big ? [.layerMaxXMinYCorner, .layerMinXMinYCorner] : [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
}

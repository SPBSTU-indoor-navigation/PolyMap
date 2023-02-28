//
//  BottomSheetPage.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.02.2022.
//

import UIKit

class BottomSheetPage: UIViewController {
    weak var delegate: BottomSheetPageDelegate?
    
    func onStateChange(verticalSize: BottomSheetViewController.VerticalSize) { }
    func onStateChange(horizontalSize: BottomSheetViewController.HorizontalSize) { }
    func onButtomSheetScroll(progress: CGFloat) { }
}

class BluredBackgroundBottomSheetPage: BottomSheetPage {
    
    var t :String = ""
    lazy var background: UIView = {
        $0.frame = view.frame
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        $0.layer.cornerRadius = 11
        $0.layer.cornerCurve = .continuous
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGroupedBackground.withAlphaComponent(0.4)
        
        let blur: UIVisualEffectView = {
            $0.frame = view.bounds
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return $0
        }(UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial)))
        
        $0.insertSubview(blur, at: 0)
        return $0
        
    }(UIView())
    
    lazy var line: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 2.5
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray2.withAlphaComponent(0.8)
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
        
        background.addSubview(line)
        NSLayoutConstraint.activate([
            line.widthAnchor.constraint(equalToConstant: 35),
            line.heightAnchor.constraint(equalToConstant: 5),
            line.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            line.topAnchor.constraint(equalTo: background.topAnchor, constant: 6)
        ])
    }
    
    override func onStateChange(horizontalSize: BottomSheetViewController.HorizontalSize) {
        super.onStateChange(horizontalSize: horizontalSize)
        background.layer.maskedCorners = horizontalSize == .big ? [.layerMaxXMinYCorner, .layerMinXMinYCorner] : [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
}

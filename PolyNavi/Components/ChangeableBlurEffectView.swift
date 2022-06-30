//
//  ChangeableBlurEffectView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 08.02.2022.
//

import UIKit

class ChangeableBlurEffectView: UIView {
    
    private lazy var blur: UIVisualEffectView = {
        $0.frame = bounds
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return $0
    }(UIVisualEffectView(effect: nil))
    
    private var blurAnimator = UIViewPropertyAnimator(duration: 3, curve: .linear)
    
    init(frame: CGRect?, style: UIBlurEffect.Style) {
        super.init(frame: frame ?? .zero)
        
        blurAnimator.addAnimations {
            self.blur.effect = UIBlurEffect(style: style)
        }
        
        blurAnimator.pausesOnCompletion = true
        
        addSubview(blur)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func update(_ progress: CGFloat) {
        print(progress)
        blurAnimator.fractionComplete = progress
    }
}

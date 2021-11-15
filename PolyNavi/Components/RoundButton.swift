//
//  RoundButton.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 14.10.2021.
//

import UIKit

class RoundButton: UIButton {
    
    
    private lazy var blur: UIVisualEffectView = {
        $0.layer.masksToBounds = true
        return $0
    }(UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial)))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //Нужно чтоб не баговало масштабирование кнопки при отсутствующем стиле
        if #available(iOS 15.0, *) {
            configuration = .plain()
        }
        blur.isUserInteractionEnabled = false
        addSubview(blur)
        if let imageView = self.imageView{
            bringSubviewToFront(imageView)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blur.frame = bounds
        blur.layer.cornerRadius = bounds.height / 2
        contentEdgeInsets = UIEdgeInsets(top: 15, left: bounds.height / 3, bottom: 15, right: bounds.height / 3)
    }
}

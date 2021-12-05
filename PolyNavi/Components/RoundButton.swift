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
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        return $0
    }(UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial)))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //Нужно чтоб не баговало масштабирование кнопки при отсутствующем стиле
        if #available(iOS 15.0, *) {
            configuration = .plain()
        }
        
        insertSubview(blur, at: 0)
        if let imageView = self.imageView{
            bringSubviewToFront(imageView)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        blur.layer.cornerRadius = blur.frame.height / 2
            
        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: topAnchor, constant: -5),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 5),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            blur.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -0)
        ])
    }
}

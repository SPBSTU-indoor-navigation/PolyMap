//
//  PopupContent.swift
//  PolyNaviClip
//
//  Created by Andrei Soprachev on 20.06.2022.
//

import UIKit

class PopupContent: UIView {
    private lazy var blur: UIVisualEffectView = {
        $0.frame = bounds
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return $0
    }(UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial)))
    
    private lazy var vibrancyLabel: UIVisualEffectView = {
        $0.frame = bounds
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return $0
    }(UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blur.effect! as! UIBlurEffect, style: .label)))
    
    private lazy var vibrancySecondaryLabel: UIVisualEffectView = {
        $0.frame = bounds
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return $0
    }(UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blur.effect! as! UIBlurEffect, style: .secondaryLabel)))
    
    
    
    private lazy var title: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.text = "Ассоциированный маршрут"
        $0.font = .preferredFont(for: .title3, weight: .bold)
        
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return $0
    }(UILabel())
    
    private lazy var message: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.text = "Эта версия блиц-приложения ассоциированна с маршрутом от м. Политехническая до Белый зал"
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.textColor = .label
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return $0
    }(UILabel())
    
    
    private lazy var fullVersionMessage: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.text = "Вы так же можете скачать полную версию"
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.textColor = .secondaryLabel
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return $0
    }(UILabel())
    
    private lazy var routeButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        
        let fullString = NSMutableAttributedString(attachment: .init(image: .init(systemName: "figure.walk")!))
        fullString.append(.init(string: " Маршрут "))
        fullString.append(NSAttributedString(attachment: .init(image: .init(systemName: "chevron.right")!)))
        
        $0.setAttributedTitle(fullString, for: .normal)
        
        $0.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        $0.titleLabel?.textColor = .label
        
        return $0
    }(UIButton())
    
    private lazy var appStoreButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        let font = UIFont.preferredFont(forTextStyle: .footnote)
        
        let fullString = NSMutableAttributedString(attachment: NSTextAttachment(image: Asset.Images.appStore.image)
            .with(imageHeight: font.pointSize * 0.9, offset: .init(x: 0, y: -font.pointSize * 0.15)))
        
        fullString.append(.init(string: " App Store "))
        fullString.append(NSAttributedString(attachment: .init(image: .init(systemName: "chevron.right")!)))
        
        $0.setAttributedTitle(fullString, for: .normal)
        $0.setTitleColor(UIColor.secondaryLabel, for: .normal)
        
        $0.titleLabel?.font = font
        
        return $0
    }(UIButton())
    
    init() {
        super.init(frame: .zero)
        
        addSubview(blur)
        
        blur.contentView.addSubview(vibrancyLabel)
        blur.contentView.addSubview(vibrancySecondaryLabel)
        vibrancyLabel.contentView.addSubview(title)
        vibrancyLabel.contentView.addSubview(message)
        vibrancySecondaryLabel.contentView.addSubview(fullVersionMessage)
        
        
        vibrancyLabel.contentView.addSubview(routeButton)
        vibrancySecondaryLabel.contentView.addSubview(appStoreButton)
        
        let insets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            title.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
            
            message.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            message.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5),
            message.trailingAnchor.constraint(lessThanOrEqualTo: routeButton.leadingAnchor, constant: -15),
            
            routeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
            routeButton.centerYAnchor.constraint(equalTo: message.centerYAnchor),
            
            fullVersionMessage.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: message.lastBaselineAnchor, multiplier: 1.5),
            fullVersionMessage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.right),
            fullVersionMessage.trailingAnchor.constraint(lessThanOrEqualTo: appStoreButton.leadingAnchor, constant: -15),
            
            appStoreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
            appStoreButton.centerYAnchor.constraint(equalTo: fullVersionMessage.centerYAnchor),
            
            bottomAnchor.constraint(equalTo: fullVersionMessage.bottomAnchor, constant: insets.bottom)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

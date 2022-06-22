//
//  PopupContent.swift
//  PolyNaviClip
//
//  Created by Andrei Soprachev on 20.06.2022.
//

import UIKit

class MessageShowRouteContent: UIView {
    
    var createRoute: (()->Void)?
    var openAppStore: (()->Void)?
    
    private lazy var blur: UIVisualEffectView = {
        $0.frame = bounds
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return $0
    }(UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial)))
    
    private lazy var vibrancyLabel: UIVisualEffectView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blur.effect! as! UIBlurEffect, style: .label)))
    
    private lazy var vibrancySecondaryLabel: UIVisualEffectView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blur.effect! as! UIBlurEffect, style: .secondaryLabel)))
    
    
    
    private lazy var title: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.text = L10n.ShareMessagePopup.title
        $0.font = .preferredFont(for: .title3, weight: .bold)
        
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return $0
    }(UILabel())
    
    private lazy var message: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.textColor = .label
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
//        $0.backgroundColor = .systemBlue
        return $0
    }(UILabel())
    
    
    private lazy var fullVersionMessage: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.text = L10n.ShareMessagePopup.appStoreMessage
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.textColor = .secondaryLabel
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return $0
    }(UILabel())
    
    private lazy var routeButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        let font = UIFont.preferredFont(forTextStyle: .footnote)
        
        let fullString = NSMutableAttributedString(attachment: .init(image: .init(systemName: "figure.walk")!))
        fullString.append(.init(string: L10n.ShareMessagePopup.routeButton))
        fullString.append(NSAttributedString(attachment: NSTextAttachment(image: Asset.Images.forward.image)
            .with(imageHeight: font.pointSize * 0.65)))
        
        $0.setAttributedTitle(fullString, for: .normal)
        
        $0.titleLabel?.font = font
        $0.titleLabel?.textColor = .label
    
        $0.addTarget(self, action: #selector(routeButtonTap), for: .touchUpInside)
        return $0
    }(UIButton())
    
    private lazy var appStoreButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        let font = UIFont.preferredFont(forTextStyle: .footnote)
        
        let fullString = NSMutableAttributedString(attachment: NSTextAttachment(image: Asset.Images.appStore.image)
            .with(imageHeight: font.pointSize * 0.9, offset: .init(x: 0, y: -font.pointSize * 0.15)))
        
        fullString.append(.init(string: L10n.ShareMessagePopup.appStoreButton))
        fullString.append(NSAttributedString(attachment: NSTextAttachment(image: Asset.Images.forward.image)
            .with(imageHeight: font.pointSize * 0.65)))
        
        $0.setAttributedTitle(fullString, for: .normal)
        $0.setTitleColor(UIColor.secondaryLabel, for: .normal)
        
        $0.titleLabel?.font = font
        
        $0.addTarget(self, action: #selector(appStoreButtonTap), for: .touchUpInside)
        return $0
    }(UIButton())
    
    init(from: Searchable, to: Searchable) {
        super.init(frame: .zero)
        
        message.text = L10n.ShareMessagePopup.message
            .replacingOccurrences(of: "{0}", with: from.mainTitle ?? from.additionalTitle ?? "")
            .replacingOccurrences(of: "{1}", with: to.mainTitle ?? to.additionalTitle ?? "")
        
        addSubview(blur)
        
        blur.contentView.addSubview(vibrancyLabel)
        blur.contentView.addSubview(vibrancySecondaryLabel)
        vibrancyLabel.contentView.addSubview(title)
        vibrancyLabel.contentView.addSubview(message)
        vibrancySecondaryLabel.contentView.addSubview(fullVersionMessage)
        
        
        vibrancyLabel.contentView.addSubview(routeButton)
        vibrancySecondaryLabel.contentView.addSubview(appStoreButton)
        
        let insets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        let offset: CGFloat = -15.0
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            title.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
            
            message.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            message.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5),
            message.trailingAnchor.constraint(lessThanOrEqualTo: routeButton.leadingAnchor, constant: offset),
            message.trailingAnchor.constraint(lessThanOrEqualTo: appStoreButton.leadingAnchor, constant: offset),
            
            routeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
            routeButton.centerYAnchor.constraint(equalTo: message.centerYAnchor),
            
            fullVersionMessage.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: message.lastBaselineAnchor, multiplier: 1.5),
            fullVersionMessage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.right),
            fullVersionMessage.trailingAnchor.constraint(lessThanOrEqualTo: routeButton.leadingAnchor, constant: offset),
            fullVersionMessage.trailingAnchor.constraint(lessThanOrEqualTo: appStoreButton.leadingAnchor, constant: offset),
            
            appStoreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
            appStoreButton.centerYAnchor.constraint(equalTo: fullVersionMessage.centerYAnchor),
            
            vibrancyLabel.topAnchor.constraint(equalTo: title.topAnchor),
            vibrancyLabel.bottomAnchor.constraint(equalTo: message.bottomAnchor),
            vibrancyLabel.leadingAnchor.constraint(equalTo: blur.leadingAnchor),
            vibrancyLabel.trailingAnchor.constraint(equalTo: blur.trailingAnchor),
            
            vibrancySecondaryLabel.topAnchor.constraint(equalTo: fullVersionMessage.topAnchor),
            vibrancySecondaryLabel.bottomAnchor.constraint(equalTo: fullVersionMessage.bottomAnchor),
            vibrancySecondaryLabel.leadingAnchor.constraint(equalTo: blur.leadingAnchor),
            vibrancySecondaryLabel.trailingAnchor.constraint(equalTo: blur.trailingAnchor),
            
            bottomAnchor.constraint(equalTo: fullVersionMessage.bottomAnchor, constant: insets.bottom)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func routeButtonTap(_ sender: UIButton) {
        createRoute?()
    }
    
    @objc func appStoreButtonTap(_ sender: UIButton) {
        openAppStore?()
    }
}

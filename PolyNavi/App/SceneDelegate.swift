//
//  SceneDelegate.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 05.10.2021.
//

import UIKit
import SwiftMessages

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

class CBaseView: BaseView {
    
    var myLayoutConstraints: [NSLayoutConstraint] = []
    var myRegularWidthLayoutConstraints: [NSLayoutConstraint] = []
    
    override func installBackgroundView(_ backgroundView: UIView, insets: UIEdgeInsets = UIEdgeInsets.zero) {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        if backgroundView != self {
            backgroundView.removeFromSuperview()
        }
        addSubview(backgroundView)
        self.backgroundView = backgroundView
        backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor).with(priority: UILayoutPriority(rawValue: 950)).isActive = true
        backgroundView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: insets.top).with(priority: UILayoutPriority(rawValue: 900)).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -insets.bottom).with(priority: UILayoutPriority(rawValue: 900)).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 350).with(priority: UILayoutPriority(rawValue: 200)).isActive = true

        myLayoutConstraints = [
            backgroundView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor, constant: insets.left).with(priority: UILayoutPriority(rawValue: 900)),
            backgroundView.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor, constant: -insets.right).with(priority: UILayoutPriority(rawValue: 900)),
        ].priority(.init(rawValue: 900))

        myRegularWidthLayoutConstraints = [
            backgroundView.leftAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leftAnchor, constant: insets.left).with(priority: UILayoutPriority(rawValue: 900)),
            backgroundView.rightAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.rightAnchor, constant: -insets.right).with(priority: UILayoutPriority(rawValue: 900)),
            backgroundView.widthAnchor.constraint(lessThanOrEqualToConstant: 600).with(priority: UILayoutPriority(rawValue: 950)),
            backgroundView.widthAnchor.constraint(equalToConstant: 600).with(priority: UILayoutPriority(rawValue: 200)),
        ]
        
    }
    
    open override func updateConstraints() {
        
        super.updateConstraints()
        
        let on: [NSLayoutConstraint]
        let off: [NSLayoutConstraint]
        switch traitCollection.horizontalSizeClass {
        case .regular:
            on = myRegularWidthLayoutConstraints
            off = myLayoutConstraints
        default:
            on = myLayoutConstraints
            off = myRegularWidthLayoutConstraints
        }
        on.forEach { $0.isActive = true }
        off.forEach { $0.isActive = false }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            updateConstraints()
        }
    }
}


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = MapViewController()
        window?.makeKeyAndVisible()
        
        if let vc = window?.rootViewController {
            if let userActivity = connectionOptions.userActivities.first {
                ShareAppOpen.open(with: userActivity, to: vc)
            } else {
                HelloMessage.open(to: vc)
            }
        }
    }
    
    static func demoAnyView() -> Void {
        let content = PopupContent()
        
        let messageView = CBaseView(frame: .zero)
        messageView.layoutMargins = .zero
        
        let backgroundView = CornerRoundingView()
        backgroundView.cornerRadius = 15
        backgroundView.layer.masksToBounds = true
        messageView.installBackgroundView(backgroundView)
        messageView.installContentView(content)
            
        backgroundView.heightAnchor.constraint(equalTo: content.heightAnchor).isActive = true
        messageView.configureDropShadow()
        
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .seconds(seconds: 5)
        SwiftMessages.show(config: config, view: messageView)
    }
    
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        SceneDelegate.demoAnyView()
        
        if let vc = window?.rootViewController {
            ShareAppOpen.open(with: userActivity, to: vc)
        }
    }
    

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}


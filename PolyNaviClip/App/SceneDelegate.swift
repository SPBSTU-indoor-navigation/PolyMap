//
//  SceneDelegate.swift
//  PolyNaviClip
//
//  Created by Andrei Soprachev on 16.02.2022.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = MapViewController()
        window?.makeKeyAndVisible()
        
        if let userActivity = connectionOptions.userActivities.first,
           let vc = window?.rootViewController {
            ShareAppOpen.open(with: userActivity, to: vc)
        }
        
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {

        if let vc = window?.rootViewController {
            ShareAppOpen.open(with: userActivity, to: vc)
        }
    }
}


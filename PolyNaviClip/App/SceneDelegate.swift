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
        defer { window?.makeKeyAndVisible() }
        
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        
        guard let userActivity = connectionOptions.userActivities.first,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL,
           let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
           let items = components.queryItems,
           let path = components.path else {
               window?.rootViewController = MapViewController()
               return
           }
            
        
        if path == "/path", let to = items.first(where: { $0.name == "to" }), let toValue = to.value {
            guard let from = items.first(where: { $0.name == "from" }), let fromValue = from.value else {
                print("to: \(toValue)")
                window?.rootViewController = MapViewController()
                return
            }
            
            print("from: \(fromValue); to: \(toValue)")
            window?.rootViewController = MapViewController()
        }
        
        window?.rootViewController = MapViewController()
        
    }
}


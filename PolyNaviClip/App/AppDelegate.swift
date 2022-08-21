//
//  AppDelegate.swift
//  PolyNaviClip
//
//  Created by Andrei Soprachev on 16.02.2022.
//

import UIKit
import YandexMobileMetrica

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let configuration = YMMYandexMetricaConfiguration.init(apiKey: "5875b583-53b6-438f-831d-deb13f993b45")
        configuration?.locationTracking = false

        YMMYandexMetrica.activate(with: configuration!)
        
    
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}


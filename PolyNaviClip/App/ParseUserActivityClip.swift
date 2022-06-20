//
//  ParseUserActivityClip.swift
//  PolyNaviClip
//
//  Created by Andrei Soprachev on 20.06.2022.
//

import Foundation
import MapKit
import SwiftMessages

class ParseUserActivityClip: ParseUserActivity {
    
    static private var lastRouteIdKey = "lastRouteId"
    
    static func demoAnyView() -> Void {
        let content = PopupContent()
        
        let messageView = СustomSwiftMessagesBaseView(frame: .zero)
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
        config.duration = .seconds(seconds: 10)
        SwiftMessages.show(config: config, view: messageView)
    }
    
    
    override func openQR(url: URL, vc: UIViewController) {
        let path = url.path
        let id = String(path.suffix(from: path.index(path.startIndex, offsetBy: 3)))
        
        if let lastID = Storage.value(key: ParseUserActivityClip.lastRouteIdKey) as? String,
           lastID == id,
           let data = ShareRouteCacheStorage.get(by: id),
           let from = PathFinder.shared.annotationById[data.from] as? Searchable,
           let to = PathFinder.shared.annotationById[data.to] as? Searchable {
            
            if let exclusiveRouteDetail = MapInfo.exclusiveRouteDetail,
               let current = exclusiveRouteDetail.currentRoute(),
               current.0.isEqual(from as? MKAnnotation),
               current.1.isEqual(to as? MKAnnotation),
               current.2 == data.routeParams,
               current.3 == data.allowParameterChange {
                //NONE
                print("CURRENT OPEN")
            } else {
                ParseUserActivityClip.demoAnyView()
                print("MESSAGE from: \(from.mainTitle); to: \(to.mainTitle)")
            }
        } else {
            OpenUrlPopup(id: id).present(to: vc, animated: true, completion: nil)
        }
        
        Storage.set(value: id, forKey: ParseUserActivityClip.lastRouteIdKey)
        
    }
}

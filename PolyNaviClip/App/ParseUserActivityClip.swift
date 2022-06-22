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
    
    func showRouteMessage(from: Searchable, to: Searchable, params: RouteParameters, allowChange: Bool) -> Void {
        let content = MessageShowRouteContent(from: from, to: to)
        
        content.createRoute = {
            MapInfo.exclusiveRouteDetail?.show(from: from.annotation, to: to.annotation, routeParams: params, allowParameterChange: allowChange)
            SwiftMessages.hide()
        }
        
        content.openAppStore = {
            if let url = URL(string: "itms-apps://apple.com/app/id1589702536") {
                UIApplication.shared.open(url)
            }
        }

        let messageView = СustomSwiftMessagesBaseView(frame: .zero)
        messageView.layoutMargins = .zero
        
        let backgroundView = CornerRoundingView()
        backgroundView.cornerRadius = 15
        backgroundView.layer.masksToBounds = true
        messageView.installBackgroundView(backgroundView, insets: .init(top: 0, left: 10, bottom: 0, right: 10))
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
               current.3 == data.allowParameterChange { } else {
                   showRouteMessage(from: from, to: to, params: data.routeParams, allowChange: data.allowParameterChange)
            }
        } else {
            OpenUrlPopup(id: id).present(to: vc, animated: true, completion: nil)
        }
        
        Storage.set(value: id, forKey: ParseUserActivityClip.lastRouteIdKey)
        
        
        
    }
}

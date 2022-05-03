//
//  CodeGeneratorAppOpen.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 23.04.2022.
//

import Foundation
import UIKit

class CodeGeneratorAppOpen {
    
    static func open(with userActivity: NSUserActivity, to vc: UIViewController) {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            
            if let url = userActivity.webpageURL {
                switch url.path {
                case "/share/route":
                    openRoute(url: url, vc: vc)
                case "/share/annotation":
                    openAnnotation(url: url, vc: vc)
                case let t where (t.count > 4 && t.prefix(3) == "/l/"):
                    openQR(url: url, vc: vc)
                default: break
                }
                
            }
        }
    }
    
    static func openRoute(url: URL, vc: UIViewController) {
        let params = parseQueryItems(url: url)
        
        if let fromStr = params["from"],
           let toStr = params["to"],
           let from = UUID(uuidString: fromStr),
           let to = UUID(uuidString: toStr) {
            let asphalt = parse(params["asphalt"]) ?? false
            let serviceRoute = parse(params["serviceroute"]) ?? false

            if let from = PathFinder.shared.annotationById[from],
               let to =  PathFinder.shared.annotationById[to] {
                MapInfo.routeDetail?.setup(from: from, to: to, routeParams: .init(asphalt: asphalt, serviceRoute: serviceRoute))
            }
        }
    }
    
    static func openAnnotation(url: URL, vc: UIViewController) {
        let params = parseQueryItems(url: url)
        if let annotationStr = params["annotation"],
           let annotationID = UUID(uuidString: annotationStr),
           let annotation = PathFinder.shared.annotationById[annotationID] {
            
            MapView.mapViewDelegate?.focusAndSelect(annotation: annotation, focusVariant: .center)
        }
    }
    
    static func openQR(url: URL, vc: UIViewController) {
        let path = url.path
        let id = String(path.suffix(from: path.index(path.startIndex, offsetBy: 3)))
        OpenUrlPopup(id: id).present(to: vc, animated: true, completion: nil)
    }
    
    static func parseQueryItems(url: URL) -> [String:String] {
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            var dict: [String:String] = [:]
            
            for item in queryItems {
                dict[item.name] = item.value!.lowercased()
            }
            
            return dict
        }
        
        return [:]
    }
    
    static func parse(_ bool: String?) -> Bool? {
        guard let bool = bool else { return nil }

        if bool.lowercased() == "false" { return false }
        if bool.lowercased() == "true" { return true }
        
        return nil
    }
}



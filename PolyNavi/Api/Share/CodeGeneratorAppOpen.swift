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
            if let url = userActivity.webpageURL,
               let id = CodeGeneratorAppOpen.pathIdByLoadUrl(url) {
                OpenUrlPopup(id: id).present(to: vc, animated: true, completion: nil)
            }
        }
    }
    
    
    static func pathIdByLoadUrl(_ url: URL) -> String? {
        
        let t = url.path.split(separator: "/")
        if t.count == 2 {
            return String(t[1])
        }
        
        return nil
    }
    
}

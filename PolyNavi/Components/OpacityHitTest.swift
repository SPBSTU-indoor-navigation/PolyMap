//
//  OpacityHitTest.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 13.04.2022.
//

import UIKit

class OpacityHitTest: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        if hit != self {
            return hit
        }
        
        return nil
    }
}

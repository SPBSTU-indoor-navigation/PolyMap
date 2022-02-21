//
//  MapInfo.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 18.02.2022.
//

import UIKit

protocol MapInfoDelegate {
    func panAction(_ sender: UIPanGestureRecognizer)
    func zoomMap(zoom: Float)
}

class MapInfo: BottomSheetViewController, MapInfoDelegate {
    func panAction(_ sender: UIPanGestureRecognizer) {
        print("panAction")
    }
    
    func zoomMap(zoom: Float) {
        print(zoom)
    }
    
    
}

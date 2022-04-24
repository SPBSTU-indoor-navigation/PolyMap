//
//  ExclusiveRouteDetailVC.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 24.04.2022.
//

import UIKit
import MapKit

class ExclusiveRouteDetailVC: NavbarBottomSheetPage {
    var mapViewDelegate: MapViewDelegate
    
    init(closable: Bool = false, mapViewDelegate: MapViewDelegate) {
        self.mapViewDelegate = mapViewDelegate
        super.init(closable: closable)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(from: MKAnnotation, to: MKAnnotation) {
    }
}

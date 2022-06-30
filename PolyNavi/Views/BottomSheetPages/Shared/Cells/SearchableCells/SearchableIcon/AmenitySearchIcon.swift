//
//  AmenitySearchIcon.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 08.05.2022.
//

import UIKit

class AmenitySearchIcon: OccupantSearchIcon {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconContainer.layer.cornerRadius = frame.width / 4
    }
}

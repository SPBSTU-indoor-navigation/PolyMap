//
//  AmenitySearchCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 08.05.2022.
//

import UIKit

class AmenitySearchCell: OccupantSearchCell {
    lazy var iconAmenity: AmenitySearchIcon = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(AmenitySearchIcon())
    
    override var icon: UIView & SearchableConfigurate {
        return iconAmenity
    }
}

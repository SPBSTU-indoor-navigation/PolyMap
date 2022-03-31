//
//  Spacer.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 02.03.2022.
//

import UIKit

class Spacer: UITableViewCell {
    static var identifire = String(describing: Spacer.self)
    
    var navbarHeightConstraint: NSLayoutConstraint?
    
    func configurate(height: CGFloat) {
        backgroundColor = .clear
        contentView.autoresizingMask = .flexibleHeight
        if let navbarHeightConstraint = navbarHeightConstraint {
            navbarHeightConstraint.constant = height
        } else {
            navbarHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: height)
            navbarHeightConstraint!.priority = .defaultHigh
            navbarHeightConstraint!.isActive = true
        }
    }
}

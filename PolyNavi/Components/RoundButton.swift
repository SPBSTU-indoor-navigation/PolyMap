//
//  RoundButton.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 14.10.2021.
//

import UIKit

class RoundButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        contentEdgeInsets = UIEdgeInsets(top: 10, left: bounds.height / 3, bottom: 10, right: bounds.height / 3)
    }
}

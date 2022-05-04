//
//  TintedUILabel.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 28.04.2022.
//

import UIKit

class TintedUILabel: UILabel {
    override func tintColorDidChange() {
        super.tintColorDidChange()
        UIView.animate(withDuration: 0.3) { [self] in
            textColor = tintColor
        }
    }
}

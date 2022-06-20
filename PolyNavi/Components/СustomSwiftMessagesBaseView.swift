//
//  СustomSwiftMessagesBaseView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 20.06.2022.
//

import UIKit
import SwiftMessages

class СustomSwiftMessagesBaseView: BaseView {
    
    var myLayoutConstraints: [NSLayoutConstraint] = []
    var myRegularWidthLayoutConstraints: [NSLayoutConstraint] = []
    
    override func installBackgroundView(_ backgroundView: UIView, insets: UIEdgeInsets = UIEdgeInsets.zero) {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        if backgroundView != self {
            backgroundView.removeFromSuperview()
        }
        addSubview(backgroundView)
        self.backgroundView = backgroundView
        backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor).with(priority: UILayoutPriority(rawValue: 950)).isActive = true
        backgroundView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: insets.top).with(priority: UILayoutPriority(rawValue: 900)).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -insets.bottom).with(priority: UILayoutPriority(rawValue: 900)).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 350).with(priority: UILayoutPriority(rawValue: 200)).isActive = true
        
        myLayoutConstraints = [
            backgroundView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor, constant: insets.left).with(priority: UILayoutPriority(rawValue: 900)),
            backgroundView.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor, constant: -insets.right).with(priority: UILayoutPriority(rawValue: 900)),
        ].priority(.init(rawValue: 900))
        
        myRegularWidthLayoutConstraints = [
            backgroundView.leftAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leftAnchor, constant: insets.left).with(priority: UILayoutPriority(rawValue: 900)),
            backgroundView.rightAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.rightAnchor, constant: -insets.right).with(priority: UILayoutPriority(rawValue: 900)),
            backgroundView.widthAnchor.constraint(lessThanOrEqualToConstant: 600).with(priority: UILayoutPriority(rawValue: 950)),
            backgroundView.widthAnchor.constraint(equalToConstant: 600).with(priority: UILayoutPriority(rawValue: 200)),
        ]
        
    }
    
    open override func updateConstraints() {
        
        super.updateConstraints()
        
        let on: [NSLayoutConstraint]
        let off: [NSLayoutConstraint]
        switch traitCollection.horizontalSizeClass {
        case .regular:
            on = myRegularWidthLayoutConstraints
            off = myLayoutConstraints
        default:
            on = myLayoutConstraints
            off = myRegularWidthLayoutConstraints
        }
        on.forEach { $0.isActive = true }
        off.forEach { $0.isActive = false }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            updateConstraints()
        }
    }
}

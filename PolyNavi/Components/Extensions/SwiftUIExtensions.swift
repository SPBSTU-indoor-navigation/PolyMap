//
//  Extensions.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.02.2022.
//

import UIKit
import SwiftUI

extension View {
    func present(to: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        to.present(UIHostingController(rootView: self), animated: flag, completion: completion)
    }
}

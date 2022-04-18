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

extension View {
    func pressAction(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActions(onPress: {
            onPress()
        }, onRelease: {
            onRelease()
        }))
    }
}


struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
    }

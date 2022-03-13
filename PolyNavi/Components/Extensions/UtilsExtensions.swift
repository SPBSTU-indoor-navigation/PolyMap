//
//  UtilsExtensions.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 07.03.2022.
//

extension Comparable {
    func clamped(_ f: Self, _ t: Self)  ->  Self {
        var r = self
        if r < f { r = f }
        if r > t { r = t }
        return r
    }
}

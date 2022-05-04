//
//  CustomBinding.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 01.05.2022.
//

class CustomBinding<T> {
    var get: ()->T
    var set: (T)->Void
    
    init(get: @escaping ()->T, set: @escaping (T)->Void) {
        self.get = get
        self.set = set
    }
}

//
//  AnnotationConvert.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 03.03.2022.
//

protocol Castable {
    func cast() -> UnitInfo
}

extension UnitAnnotation: Castable {
    func cast() -> UnitInfo {
        
        let res = UnitInfo()
        res.title = properties.name?.bestLocalizedValue ?? title ?? "-"
        
        return res
    }
}

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
        
        res.sections.append(UnitInfo.Route(showRoute: true, showIndoor: true))
        res.sections.append(UnitInfo.Detail(phone: "7 931 203 27 68", website: "www.soprachev.com", address: "Line1\nLine2"))
        res.sections.append(UnitInfo.Report())
        
        return res
    }
}

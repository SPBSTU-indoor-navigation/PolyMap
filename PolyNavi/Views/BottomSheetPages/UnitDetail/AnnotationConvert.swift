//
//  AnnotationConvert.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 03.03.2022.
//

protocol Castable {
    func cast() -> OccupantInfo
}

extension OccupantAnnotation: Castable {
    func cast() -> OccupantInfo {
        
        let res = OccupantInfo()
        res.title = properties.name?.bestLocalizedValue ?? title ?? "-"
        
        res.sections.append(OccupantInfo.Route(showRoute: true, showIndoor: true))
        res.sections.append(OccupantInfo.Detail(phone: self.properties.phone, email: self.properties.email, website: self.properties.website, address: self.address?.addressString()))
        res.sections.append(OccupantInfo.Report())
        
        return res
    }
}

extension IMDF.Address {
    func addressString() -> String {
        var result = ""
        
        if let unit = properties.unit { result += "\(unit)"}
        if let address = properties.address { result += "\n\(address)"}
        if let postalCode = properties.postal_code { result += "\n\(postalCode)"}
        
        return result
    }
}

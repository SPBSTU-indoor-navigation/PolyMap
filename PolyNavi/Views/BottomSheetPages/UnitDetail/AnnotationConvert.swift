//
//  AnnotationConvert.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 03.03.2022.
//

protocol Castable {
    func cast() -> MapDetailInfo
}

extension OccupantAnnotation: Castable {
    func cast() -> MapDetailInfo {
        
        let res = MapDetailInfo()
        res.title = properties.name?.bestLocalizedValue ?? title ?? "-"
        
        res.sections.append(MapDetailInfo.Route(showRoute: true, showIndoor: false))
        res.sections.append(MapDetailInfo.Detail(phone: properties.phone, email: properties.email, website: properties.website, address: address?.addressString()))
        res.sections.append(MapDetailInfo.Report())
        
        res.annotation = self
        
        return res
    }
}

extension AmenityAnnotation: Castable {
    func cast() -> MapDetailInfo {
        let res = MapDetailInfo()
        
        res.title = properties.name?.bestLocalizedValue ?? title ?? "-"
        res.sections.append(MapDetailInfo.Route(showRoute: true, showIndoor: false))
        res.sections.append(MapDetailInfo.Report(favorite: false, report: true))
        
        res.annotation = self
        
        return res
    }
}

extension EnviromentAmenityAnnotation: Castable {
    func cast() -> MapDetailInfo {
        let res = MapDetailInfo()
        
        res.title = properties.name?.bestLocalizedValue ?? title ?? "-"
        res.sections.append(MapDetailInfo.Route(showRoute: true, showIndoor: false))
        res.sections.append(MapDetailInfo.Report(favorite: false, report: true))
        
        res.annotation = self
        
        return res
    }
}

extension AttractionAnnotation: Castable {
    func cast() -> MapDetailInfo {
        let res = MapDetailInfo()
        
        res.title = properties.name?.bestLocalizedValue ?? title ?? "-"
        res.sections.append(MapDetailInfo.Route(showRoute: true, showIndoor: true).with(buildingID: properties.building_id))
        res.sections.append(MapDetailInfo.Report(favorite: true, report: true))
        
        res.annotation = self
        
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

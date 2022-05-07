//
//  AnnotationConvert.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 03.03.2022.
//

protocol MapDetailInfoCastable {
    func cast(mapDetailInfo: MapDetailInfo) -> Void
}

extension OccupantAnnotation: MapDetailInfoCastable {
    func cast(mapDetailInfo: MapDetailInfo) -> Void {
        mapDetailInfo.title = properties.name?.bestLocalizedValue ?? title ?? "-"
        
        mapDetailInfo.sections.append(MapDetailInfo.Route(showRoute: true, showIndoor: false, annotation: self))
        mapDetailInfo.sections.append(MapDetailInfo.Detail(phone: properties.phone, email: properties.email, website: properties.website, address: address?.addressString()))
        mapDetailInfo.sections.append(MapDetailInfo.Share(annotation: self))
        mapDetailInfo.sections.append(MapDetailInfo.Report(favorite: true, report: SectionCollection.Report.ReportAnnotation(annotation: self)))
        
        mapDetailInfo.annotation = self
    }
}

extension AmenityAnnotation: MapDetailInfoCastable {
    func cast(mapDetailInfo: MapDetailInfo) -> Void {
        mapDetailInfo.title = properties.name?.bestLocalizedValue ?? title ?? "-"
        mapDetailInfo.sections.append(MapDetailInfo.Route(showRoute: true, showIndoor: false, annotation: self))
        mapDetailInfo.sections.append(MapDetailInfo.Report(favorite: false, report: SectionCollection.Report.ReportAnnotation(annotation: self)))
        
        mapDetailInfo.annotation = self
    }
}

extension EnviromentAmenityAnnotation: MapDetailInfoCastable {
    func cast(mapDetailInfo: MapDetailInfo) -> Void {

        mapDetailInfo.title = properties.name?.bestLocalizedValue ?? title ?? "-"
        mapDetailInfo.sections.append(MapDetailInfo.Route(showRoute: true, showIndoor: false, annotation: self))
        mapDetailInfo.sections.append(MapDetailInfo.Report(favorite: false, report: SectionCollection.Report.ReportAnnotation(annotation: self)))
        
        mapDetailInfo.annotation = self
    }
}

extension AttractionAnnotation: MapDetailInfoCastable {
    func cast(mapDetailInfo: MapDetailInfo) -> Void {

        mapDetailInfo.title = properties.name?.bestLocalizedValue ?? title ?? "-"
        mapDetailInfo.sections.append(MapDetailInfo.Route(showRoute: true, showIndoor: true, annotation: self).with(buildingID: properties.building_id))
        mapDetailInfo.sections.append(MapDetailInfo.Share(annotation: self))
        mapDetailInfo.sections.append(MapDetailInfo.Report(favorite: true, report: SectionCollection.Report.ReportAnnotation(annotation: self)))
        
        mapDetailInfo.annotation = self
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

//
//  AnnotationConvert.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 03.03.2022.
//

protocol UnitDetailInfoCastable {
    func cast(unitDetailInfo: UnitDetailInfo) -> Void
}

extension OccupantAnnotation: UnitDetailInfoCastable {
    func cast(unitDetailInfo: UnitDetailInfo) -> Void {
        unitDetailInfo.title = properties.name?.bestLocalizedValue ?? title ?? "-"
        
        unitDetailInfo.sections.append(UnitDetailInfo.Route(showRoute: true, showIndoor: false, annotation: self))
        unitDetailInfo.sections.append(UnitDetailInfo.Detail(phone: properties.phone, email: properties.email, website: properties.website, address: address?.addressString()))
        unitDetailInfo.sections.append(UnitDetailInfo.Share(annotation: self))
        unitDetailInfo.sections.append(UnitDetailInfo.Report(favorite: self, report: SectionCollection.Report.ReportAnnotation(annotation: self)))
        
        unitDetailInfo.annotation = self
    }
}

extension AmenityAnnotation: UnitDetailInfoCastable {
    func cast(unitDetailInfo: UnitDetailInfo) -> Void {
        unitDetailInfo.title = properties.name?.bestLocalizedValue ?? title ?? "-"
        unitDetailInfo.sections.append(UnitDetailInfo.Route(showRoute: true, showIndoor: false, annotation: self))
        unitDetailInfo.sections.append(UnitDetailInfo.Report(favorite: self, report: SectionCollection.Report.ReportAnnotation(annotation: self)))
        
        unitDetailInfo.annotation = self
    }
}

extension EnviromentAmenityAnnotation: UnitDetailInfoCastable {
    func cast(unitDetailInfo: UnitDetailInfo) -> Void {

        unitDetailInfo.title = properties.name?.bestLocalizedValue ?? title ?? "-"
        unitDetailInfo.sections.append(UnitDetailInfo.Route(showRoute: true, showIndoor: false, annotation: self))
        unitDetailInfo.sections.append(UnitDetailInfo.Report(favorite: self, report: SectionCollection.Report.ReportAnnotation(annotation: self)))
        
        unitDetailInfo.annotation = self
    }
}

extension AttractionAnnotation: UnitDetailInfoCastable {
    func cast(unitDetailInfo: UnitDetailInfo) -> Void {

        unitDetailInfo.title = properties.name?.bestLocalizedValue ?? title ?? "-"
        unitDetailInfo.sections.append(UnitDetailInfo.Route(showRoute: true, showIndoor: true, annotation: self).with(building: building))
        unitDetailInfo.sections.append(UnitDetailInfo.Share(annotation: self))
        unitDetailInfo.sections.append(UnitDetailInfo.Report(favorite: self, report: SectionCollection.Report.ReportAnnotation(annotation: self)))
        
        unitDetailInfo.annotation = self
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

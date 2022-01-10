//
//  Feature.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 08.01.2022.
//

import Foundation
import MapKit

enum Restriction: String, Codable {
    case employeesonly = "employeesonly"
    case restricted = "restricted"
}

struct PointGeometry: Codable {
//    let type: String = "Point"
    let coordinates: [Double]
    
    func getCoordinates() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: coordinates.last!, longitude: coordinates.first!)
    }
}

class Feature<Properties: Decodable>: NSObject, IMDFDecodableFeature {
    let identifier: UUID
    let properties: Properties
    let geometry: [MKShape & MKGeoJSONObject]
    
    required init(feature: MKGeoJSONFeature) throws {
        identifier = UUID(uuidString: feature.identifier!)!
        geometry = feature.geometry
        
        if let propertiesData = feature.properties {
            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
            properties = try decoder.decode(Properties.self, from: propertiesData)
        } else {
            throw IMDFError.invalidData
        }
        
        super.init()
    }
}

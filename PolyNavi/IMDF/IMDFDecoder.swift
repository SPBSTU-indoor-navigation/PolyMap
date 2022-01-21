//
//  IMDFDecoder.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 08.01.2022.
//

import Foundation
import MapKit
import M13Checkbox

protocol IMDFDecodableFeature {
    init(feature: MKGeoJSONFeature) throws
}

enum IMDFError: Error {
    case invalidType
    case invalidData
}

enum File {
    case address
    case amenity
    case anchor
    case building
    case detail
    case fixture
    case footprint
    case geofence
    case kiosk
    case level
    case manifest
    case occupant
    case opening
    case relationship
    case section
    case unit
    case venue
    case enviroment
    case enviromentAmenity
    case attraction
    case enviromentDetail
    
    var filename: String {
        return "\(self).geojson"
    }
    
    func fileURL(_ baseDirectory: URL) -> URL {
        return baseDirectory.appendingPathComponent(self.filename)
    }
}

class IMDFDecoder {
    static func decode(_ path: URL) -> Venue? {
        
        let addresses = try! decodeFeatures(IMDF.Address.self, path: File.address.fileURL(path))
        let addressesByID = Dictionary(uniqueKeysWithValues: addresses.map{ ($0.identifier, $0) })
        
        
        let venues = try! decodeFeatures(IMDF.Venue.self, path: File.venue.fileURL(path))
        let imdfBuildings = try! decodeFeatures(IMDF.Building.self, path: File.building.fileURL(path))
        let imdfLevels = try! decodeFeatures(IMDF.Level.self, path: File.level.fileURL(path))
        let imdfUnits = try! decodeFeatures(IMDF.Unit.self, path: File.unit.fileURL(path))
        let imdfOpening = try! decodeFeatures(IMDF.Opening.self, path: File.opening.fileURL(path))
        let amenitys = try! decodeFeatures(IMDF.Amenity.self, path: File.amenity.fileURL(path))
        let enviroments = try! decodeFeatures(IMDF.EnviromentUnit.self, path: File.enviroment.fileURL(path))
        let enviromentAmenitys = try! decodeFeatures(IMDF.EnviromentAmenity.self, path: File.enviromentAmenity.fileURL(path))
        let enviromentDetail = try! decodeFeatures(IMDF.EnviromentDetail.self, path: File.enviromentDetail.fileURL(path))
        let attraction = try! decodeFeatures(IMDF.Attraction.self, path: File.attraction.fileURL(path))
        
        
        guard let venue = venues.first else { return nil }
        
        let buildings = imdfBuildings.map({ building in
            return Building(building.geometry.overlay(),
                            levels: imdfLevels
                                .filter({ $0.properties.building_ids.contains(building.identifier) })
                                .map({ $0.cast(units: imdfUnits, openings: imdfOpening, amenitys: amenitys)}),
                            attractions: attraction.filter({ $0.properties.building_id == building.identifier }))
        })
        
        let result = Venue(geometry: venue.geometry.overlay(),
                           buildings: buildings,
                           enviroments: enviroments.map({ $0.cast() }),
                           enviromentDetail: enviromentDetail.map({ $0.cast() }),
                           address: addressesByID[venue.properties.address_id],
                           amenitys: enviromentAmenitys)
        return result
    }
    
    static func decodeFeatures<T: IMDFDecodableFeature>(_ type: T.Type, path: URL) throws -> [T] {
        let data = try Data(contentsOf: path)
        let geoJSONFeatures = try MKGeoJSONDecoder().decode(data)
        
        guard let features = geoJSONFeatures as? [MKGeoJSONFeature] else {
            throw IMDFError.invalidType
        }
        
        let imdfFeatures = try features.map { try type.init(feature: $0) }
        return imdfFeatures
    }
    
}

extension IMDF.Level {
    func cast(units: [IMDF.Unit], openings: [IMDF.Opening], amenitys: [IMDF.Amenity]) -> Level {
        let units = units.filter({ $0.properties.level_id == self.identifier })
        let unitsIds = Set(units.map({ $0.identifier }))
        let amenitysFiltred = amenitys.filter({ !unitsIds.intersection($0.properties.unit_ids).isEmpty })
        
        
        return Level(self.geometry.overlay(),
                     ordinal: self.properties.ordinal,
                     units: units.map{ $0.cast() },
                     openings: openings.filter({ $0.properties.level_id == self.identifier }).map({ $0.cast() }),
                     shortName: self.properties.short_name,
                     amenitys: amenitysFiltred)
    }
}

extension IMDF.Unit {
    func cast() -> Unit {
        let properties = self.properties
        
        return Unit(self.geometry.overlay(),
                    id: self.identifier,
                    displayPoint: properties.display_point?.getCoordinates(),
                    name: properties.name,
                    altName: properties.alt_name,
                    categoty: properties.category,
                    restriction: properties.restriction)
    }
}

extension IMDF.EnviromentUnit {
    func cast()-> EnviromentUnit {
        return EnviromentUnit(self.geometry.overlay(), category: properties.category)
    }
}

extension IMDF.Opening {
    func cast() -> Opening {
        return Opening(geometry: self.geometry.overlay(), unitCategory: self.properties.unit_categoty)
    }
}

extension IMDF.EnviromentDetail {
    func cast() -> EnviromentDetail {
        return try! EnviromentDetail(geometry: self.geometry.overlay(), category: self.properties.category)
    }
}

extension Array where Element == MKShape & MKGeoJSONObject {
//    func polygon() -> [MKPolygon] {
//        if let geometry = self.first as? MKPolygon {
//            return [geometry]
//        } else if let geometry = self.first as? MKMultiPolygon {
//            return geometry.polygons
//        }
//        return []
//    }
    
    func overlay() -> MKShape & MKOverlay {
        return self.first as! MKShape & MKOverlay
    }
}


//
//  IMDFDecoder.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 08.01.2022.
//

import Foundation
import MapKit

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
        
        
        guard let venue = venues.first else { return nil }
        
        let buildings = imdfBuildings.map({ building in
            return Building(geometry(building.geometry),
                            levels: imdfLevels
                                .filter({ $0.properties.building_ids.contains(building.identifier) })
                                .map({ level in
                Level(geometry(level.geometry),
                      ordinal: level.properties.ordinal,
                      units: imdfUnits
                        .filter({ $0.properties.level_id == level.identifier })
                        .map({ Unit(geometry($0.geometry), $0.properties.category) }),
                      openings: imdfOpening
                        .filter({ $0.properties.level_id == level.identifier })
                        .map({ opening in
                            let t = opening.geometry.first as! MKPolyline
                            return Opening(points: t.points(), count: t.pointCount)
                }))
                
            }))
        })
        
        let result = Venue(geometry: geometry(venue.geometry),
                           buildings: buildings,
                           address: addressesByID[venue.properties.address_id])
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
    
    static func geometry(_ geometry: [MKShape]) -> [MKPolygon] {
        if let geometry = geometry.first as? MKPolygon {
            return [geometry]
        } else if let geometry = geometry.first as? MKMultiPolygon {
            return geometry.polygons
        }
        return []
    }
}

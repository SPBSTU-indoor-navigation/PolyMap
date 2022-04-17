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
    case enviroment
    case enviromentAmenity
    case attraction
    case navPath
    case navPathAssocieted
    
    var filename: String {
        return "\(self).geojson"
    }
    
    func fileURL(_ baseDirectory: URL) -> URL {
        return baseDirectory.appendingPathComponent(self.filename)
    }
}

class IMDFDecoder {
    static var defaultPathStartPoint: MKAnnotation?
    
    static func decode(_ path: URL) -> Venue? {
        
        let addresses = try! decodeFeatures(IMDF.Address.self, path: File.address.fileURL(path))
        let addressesByID = Dictionary(uniqueKeysWithValues: addresses.map{ ($0.identifier, $0) })
        
        
        let venues = try! decodeFeatures(IMDF.Venue.self, path: File.venue.fileURL(path))
        let imdfBuildings = try! decodeFeatures(IMDF.Building.self, path: File.building.fileURL(path))
        let imdfLevels = try! decodeFeatures(IMDF.Level.self, path: File.level.fileURL(path))
        let imdfUnits = try! decodeFeatures(IMDF.Unit.self, path: File.unit.fileURL(path))
        let imdfOpening = try! decodeFeatures(IMDF.Opening.self, path: File.opening.fileURL(path))
        let detail = try! decodeFeatures(IMDF.Detail.self, path: File.detail.fileURL(path))
        let anchor = try! decodeFeatures(IMDF.Anchor.self, path: File.anchor.fileURL(path))
        let occupant = try! decodeFeatures(IMDF.Occupant.self, path: File.occupant.fileURL(path))
        let amenitys = try! decodeFeatures(IMDF.Amenity.self, path: File.amenity.fileURL(path))
        let enviroments = try! decodeFeatures(IMDF.EnviromentUnit.self, path: File.enviroment.fileURL(path))
        let enviromentAmenitys = try! decodeFeatures(IMDF.EnviromentAmenity.self, path: File.enviromentAmenity.fileURL(path))
        let attraction = try! decodeFeatures(IMDF.Attraction.self, path: File.attraction.fileURL(path))
        let navPath = try! decodeFeatures(IMDF.NavPath.self, path: File.navPath.fileURL(path))
        let navPathAssocieted = try! decodeFeatures(IMDF.NavPathAssocieted.self, path: File.navPathAssocieted.fileURL(path))
        
        
        guard let venue = venues.first else { return nil }
        
        let occupantAnchor: [(IMDF.Occupant, IMDF.Anchor)] = occupant.map({ occupant in
            return (occupant, anchor.first(where: { $0.identifier == occupant.properties.anchor_id })!)
        })
        
        let levelById = imdfLevels.reduce([UUID:Level](), { dict, level in
            var dict = dict
            dict[level.identifier] = level.cast(units: imdfUnits, openings: imdfOpening, amenitys: amenitys, details: detail,
                                                occupantAnchor: occupantAnchor, addresses: addresses)
            return dict
        })
        
        let builingById = imdfBuildings.reduce([UUID:Building](), { dict, building in
            var dict = dict
            dict[building.identifier] = Building(building.geometry.overlay(),
                     levels: levelById.values.filter({ $0.properties.building_ids.contains(building.identifier) }),
                     attractions: attraction.filter({ $0.properties.building_id == building.identifier }),
                     properties: building.properties)
            return dict
        })
        
        let result = Venue(geometry: venue.geometry.overlay(),
                          buildings: Array(builingById.values),
                          enviroments: enviroments.map({ $0.cast() }),
                          enviromentDetail: detail.filter({ $0.properties.level_id == nil }).map({ $0.cast() }),
                          address: addressesByID[venue.properties.address_id],
                          amenitys: enviromentAmenitys)
        
        
        let annotationIds: [UUID:MKAnnotation] =
            (
                result.amenitys.map({ ($0.imdfID!, $0 as MKAnnotation) }) +
                result.buildings.flatMap({ $0.attractions.map({ ($0.imdfID!, $0 as MKAnnotation) }) }) +
                result.buildings.flatMap({ $0.levels.flatMap({ $0.amenitys.map({ ($0.imdfID!, $0 as MKAnnotation) }) }) }) +
                result.buildings.flatMap({ $0.levels.flatMap({ $0.occupants.map({ ($0.imdfID!, $0 as MKAnnotation) }) }) })
            ).reduce([UUID:MKAnnotation](), { dict, node in
                var dict = dict
                dict[node.0] = node.1
                return dict
            })
            
        PathFinder.shared.setup(navPath: navPath, associeted: navPathAssocieted, buildings: builingById, levels: levelById, annotations: annotationIds)
        
    
        if let id = venue.properties.navpath_begin_id {
            defaultPathStartPoint = annotationIds[id]
        } else {
            defaultPathStartPoint = nil
        }
    
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
    func cast(units: [IMDF.Unit], openings: [IMDF.Opening], amenitys: [IMDF.Amenity], details: [IMDF.Detail], occupantAnchor: [(IMDF.Occupant, IMDF.Anchor)], addresses: [IMDF.Address]) -> Level {
        let units = units.filter({ $0.properties.level_id == self.identifier })
        let unitsIds = Set(units.map({ $0.identifier }))
        let amenitysFiltred = amenitys.filter({ !unitsIds.intersection($0.properties.unit_ids).isEmpty })
        let occupants = occupantAnchor.filter({ unitsIds.contains($0.1.properties.unit_id)})
        
        return Level(self.geometry.overlay(),
                     units: units.map({ $0.cast() }),
                     openings: openings.filter({ $0.properties.level_id == self.identifier }).map({ $0.cast() }),
                     properties: self.properties,
                     amenitys: amenitysFiltred,
                     details: details.filter({ $0.properties.level_id == self.identifier }).map({ $0.cast() }),
                     occupants: occupants,
                     addresses: addresses)
    }
}

extension IMDF.Unit {
    func cast() -> Unit {
        let properties = self.properties
        
        return Unit(self.geometry.overlay(),
                    id: self.identifier,
                    displayPoint: properties.display_point?.getCoordinates(),
                    properties: self.properties)
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

extension IMDF.Detail {
    func cast() -> Detail {
        return try! Detail(geometry: self.geometry.overlay(), category: self.properties.category)
    }
}

extension Array where Element == MKShape & MKGeoJSONObject {
    func overlay() -> MKShape & MKOverlay {
        return self.first as! MKShape & MKOverlay
    }
}


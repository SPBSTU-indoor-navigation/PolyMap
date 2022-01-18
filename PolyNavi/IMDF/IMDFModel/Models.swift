//
//  Object.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 08.01.2022.
//

import Foundation
import MapKit

struct IMDF {
    class Venue: Feature<Venue.Properties> {
        struct Properties: Codable {
            let category: String
            let hours: String
            let phone: String
            let website: String
            let address_id: UUID
        }
    }
    
    class Building: Feature<Building.Properties> {
        struct Properties: Codable {
            let name: LocalizedName?
            let alt_name: LocalizedName?
            let category: String
            let restriction: Restriction?
            let address_id: UUID?
            
            let display_point: PointGeometry?
        }
    }
    
    class Level: Feature<Level.Properties> {
        struct Properties: Codable {
            let name: LocalizedName?
            let short_name: LocalizedName?
            
            let ordinal: Int
            let outdoor: Bool
            let category: String
            let restriction: Restriction?
            let address_id: UUID?
            let building_ids: [UUID]
            let display_point: PointGeometry?
        }
    }
    
    class Unit: Feature<Unit.Properties> {
        enum Category: String, Codable {
            case auditorium
            case brick
            case classroom
            case column
            case concrete
            case conferenceroom
            case drywall
            case elevator
            case escalator
            case fieldofplay
            case firstaid
            case fitnessroom
            case foodservice
            case footbridge
            case glass
            case huddleroom
            case kitchen
            case laboratory
            case library
            case lobby
            case lounge
            case mailroom
            case mothersroom
            case movietheater
            case movingwalkway
            case nonpublic
            case office
            case opentobelow
            case parking
            case phoneroom
            case platform
            case privatelounge
            case ramp
            case recreation
            case restroom
            case restroomFamily = "restroom.family"
            case restroomFemale = "restroom.female"
            case restroomFemaleWheelchair = "restroom.female.wheelchair"
            case restroomMale = "restroom.male"
            case restroomMaleWheelchair = "restroom.male.wheelchair"
            case restroomTransgender = "restroom.transgender"
            case restroomTransgenderWheelchair = "restroom.transgender.wheelchair"
            case restroomUnisex = "restroom.unisex"
            case restroomUnisexWheelchair = "restroom.unisex.wheelchair"
            case restroomWheelchair = "restroom.wheelchair"
            case road
            case room
            case serverroom
            case shower
            case smokingarea
            case stairs
            case steps
            case storage
            case structure
            case terrace
            case theater
            case unenclosedarea
            case unspecified
            case vegetation
            case waitingroom
            case walkway
            case walkwayIsland = "walkway.island"
            case wood
        }
        
        struct Properties: Codable {
            let name: LocalizedName?
            let alt_name: LocalizedName?
            
            let level_id: UUID
            let category: Category
            let restriction: Restriction?
            let display_point: PointGeometry?
        }
    }
    
    class Opening: Feature<Opening.Properties> {
        struct Door: Codable {
            let type: String
            let material: String
            let automatic: Bool
        }
        
        struct Properties: Codable {
            let name: LocalizedName?
            let alt_name: LocalizedName?
            
            let level_id: UUID
            let category: String
            let unit_categoty: IMDF.Unit.Category?
            let door: Door
            let display_point: PointGeometry?
        }
    }
    
    class EnviromentUnit: Feature<EnviromentUnit.Properties> {
        enum Category: String, Codable {
            case roadMain = "road.main"
            case roadDirt = "road.dirt"
            case roadPedestrianMain = "road.pedestrian.main"
            case grass
            case tree
            case forest
        }
        
        struct Properties: Codable {
            let name: LocalizedName?
            let alt_name: LocalizedName?
            let category: Category
            let display_point: PointGeometry?
        }
    }
    
    class Address: Feature<Address.Properties> {
        struct Properties: Codable {
            let address: String?
            let unit: String?
            let locality: String?
            let province: String?
            let country: String?
            let postal_code: String?
            let postal_code_ext: String?
            let postal_code_vanity: String?
        }
    }
    
    class EnviromentAmenity: Feature<EnviromentAmenity.Properties> {
        
        enum Category: String, Codable {
            case parkingCar = "parking.car"
            case parkingBicycle = "parking.bicycle"
        }
        
        struct Properties: Codable {
            let name: LocalizedName?
            let alt_name: LocalizedName?
            let category: Category
            let detailLevel: Int
        }
    }
    
    class Amenity: Feature<Amenity.Properties> {
        
        enum Category: String, Codable {
            case atm //Банкомат
            case copymachine
            case eatingdrinking
            case elevator
            case escalator
            case entry //вход
            case faregate //пропускной вход
            case information
            case library
            case restroom
            case restroomFemale = "restroom.female"
            case restroomMale = "restroom.male"
            case seat
            case security
            case securityCheckpoint = "security.checkpoint"
            case smokingarea
            case studentservices
            case swimmingpool
            case vendingmachine
            case unspecified
            case stairs
        }
        
        struct Properties: Codable {
            let name: LocalizedName?
            let alt_name: LocalizedName?
            let unit_ids: [UUID]
            
            let category: Category
            let detailLevel: Int
            
            let hours: String?
            let phone: String?
            let website: String?
            let address_id: UUID?
        }
    }
    
    class Attraction: Feature<Attraction.Properties> {
        
        enum Category: String, Codable {
            case building
        }
        
        struct Properties: Codable {
            let name: LocalizedName?
            let alt_name: LocalizedName?
            let short_name: LocalizedName?
            let building_id: UUID
            
            let category: Category
            let image: String?
        }
    }
    
}



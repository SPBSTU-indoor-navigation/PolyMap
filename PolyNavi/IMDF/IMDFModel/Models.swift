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
            let navpath_begin_id: UUID?
        }
    }
    
    class Building: Feature<Building.Properties> {
        struct Properties: Codable {
            let name: LocalizedName?
            let alt_name: LocalizedName?
            let category: String
            let restriction: Restriction?
            let address_id: UUID?
            var rotation: CGFloat?
            
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
            case administration
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
            case foodserviceСoffee = "foodservice.coffee"
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
            case security
            case stairs
            case shop
            case steps
            case storage
            case structure
            case terrace
            case theater
            case unenclosedarea
            case unspecified
            case vegetation
            case waitingroom
            case wardrobe
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
            case roadPedestrianSecond = "road.pedestrian.second"
            case roadPedestrianTreadmill = "road.pedestrian.treadmill"
            case grass
            case grassStadion = "grass.stadion"
            case tree
            case forest
            case fenceMain = "fence.main"
            case fenceSecond = "fence.second"
            case sand
            case water
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
            case banch = "banch"
            case metro = "metro"
            case transportBus = "transport.bus"
            case transportTrum = "transport.trum"
            case stadium = "stadium"
            case stadiumFootball = "stadium.football"
            case stadiumBasketball = "stadium.basketball"
            case stadiumVolleyball = "stadium.volleyball"
            case entrance = "entrance"
            case playground = "playground"
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
    
    class Detail: Feature<Detail.Properties> {
        
        enum Category: String, Codable {
            case crosswalk = "crosswalk"
            case roadMarkingMain = "road.marking.main"
            case parkingMarking = "parking.marking"
            case parkingBig = "parking.big"
            case fenceMain = "fence.main"
            case fenceHeigth = "fence.heigth"
            case steps = "steps"
            case indoorSteps = "indoor.steps"
            case indoorStairs = "indoor.stairs"
            case treadmillMarking = "treadmill.marking"
            case stadionGrassMarking = "stadion.grass.marking"
        }
        
        struct Properties: Codable {
            let category: Category
            let level_id: UUID?
        }
    }
    
    class Anchor: Feature<Anchor.Properties> {
        struct Properties: Codable {
            let unit_id: UUID
            let address_id: UUID?
        }
    }
    
    class Occupant: Feature<Occupant.Properties> {
        
        enum Category: String, Codable {
            case auditorium = "auditorium"
            case administration = "administration"
            case classroom = "classroom"
            case laboratory = "laboratory"
            case library = "library"
            case souvenirs = "souvenirs"
            case foodserviceСoffee = "foodservice.coffee"
            case security = "security"
            case wardrobe = "wardrobe"
            case unspecified = "unspecified"
            case restroom = "restroom"
            case restroomFemale = "restroom.female"
            case restroomMale = "restroom.male"
        }
        
        struct Properties: Codable {
            let name: LocalizedName?
            let shortName: LocalizedName?
            let category: Category
            let anchor_id: UUID
            let hours: String?
            let phone: String?
            let email: String?
            let website: String?
            
            let correlation_id: UUID?
        }
    }
    
    class NavPath: Feature<NavPath.Properties> {
        struct Properties: Codable {
            let builing_id: UUID?
            let level_id: UUID?
            let neighbours: [UUID]
        }
    }
    
    class NavPathAssocieted: Feature<NavPathAssocieted.Properties> {
        struct Properties: Codable {
            let pathNode_id: UUID
            let associeted_id: UUID
        }
    }
    
}



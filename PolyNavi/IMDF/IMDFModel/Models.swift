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
        struct Properties: Codable {
            let name: LocalizedName?
            let alt_name: LocalizedName?
            
            let level_id: UUID
            let category: String
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
            let door: Door
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
    
}



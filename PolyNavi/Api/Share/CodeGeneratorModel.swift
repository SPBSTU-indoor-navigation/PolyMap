//
//  CodeGeneratorModel.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 20.04.2022.
//

import Foundation

struct CodeGeneratorModel {
    struct ServerStatus: Codable {
        let status: String
        let appclip: Bool
        let qr: Bool
    }
    
    struct GenerateResponse: Codable {
        let codeID: String
        let base: String
        let codeUrl: String
    }
    
    struct DataResponse: Codable {
        let from: UUID
        let to: UUID
        let helloText: String
        let asphalt: Bool
        let serviceRoute: Bool
        let allowParameterChange: Bool
        
        var routeParams: RouteParameters {
            return .init(asphalt: asphalt, serviceRoute: serviceRoute)
        }
    }
}

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
    }
    
    struct GenerateResponse: Codable {
        let appClipID: Int
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
    }
}

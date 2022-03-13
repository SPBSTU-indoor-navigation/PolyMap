//
//  LocalizedName.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 08.01.2022.
//

import Foundation

struct LocalizedName: Codable {
    private let localizations: [String: String]
    
    init(localizations: [String: String]) {
        self.localizations = localizations
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.localizations = try container.decode([String: String].self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(localizations)
    }
    
    var bestLocalizedValue: String? {
        for languageCode in NSLocale.preferredLanguages {
            if let localizedValue = localizations[languageCode] {
                return localizedValue
            }
        }
        
        return localizations["ru"]
    }
}

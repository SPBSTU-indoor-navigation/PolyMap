//
//  ShareRouteCacheStorage.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 20.06.2022.
//

import Foundation

class ShareRouteCacheStorage {
    static private let key = "shareRouteCacheStorage"
    static private let keyForKeys = "shareRouteCacheStorageKeys"
    
    static func get(by id: String) -> CodeGeneratorModel.DataResponse? {
        if let key = key(by: id),
           let data = Storage.value(key: key) as? Data,
           let route = try? JSONDecoder().decode(CodeGeneratorModel.DataResponse.self, from: data) {
            return route
        }
                
        return nil
    }
    
    static func save(id: String, route: CodeGeneratorModel.DataResponse) {
        
        if let allKeys = Storage.value(key: keyForKeys) as? [String] {
            if allKeys.count > 10 {
                Storage.remove(key: allKeys[0])
            }
        }
        
        if let key = key(by: id),
           let data = try? JSONEncoder().encode(route) {
            Storage.set(value: data, forKey: key)
        }
    }
    
    static private func key(by id: String) -> String? {
        if !id.isEmpty && id.count < 10 {
            return "\(key)_\(id)"
        }
        
        return nil
    }
}

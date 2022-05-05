//
//  UserDefaultsStorage.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 04.05.2022.
//

import Foundation


class Storage {
    enum Constants {
        static let group = "group.com.soprachev.polymap.clipGroup"
    }
    
    static let shared: Storage = Storage()
    
    let userDefaults = UserDefaults(suiteName: Constants.group) ?? UserDefaults.standard
    
    func value(key: String) -> Any? {
        return userDefaults.value(forKey: key)
    }
    
    func set(value: Any, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    static func value(key: String) -> Any? {
        return Storage.shared.value(key: key)
    }
    
    static func set(value: Any, forKey key: String) {
        Storage.shared.set(value: value, forKey: key)
    }
}

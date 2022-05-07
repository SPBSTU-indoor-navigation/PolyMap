//
//  FavoritesStorage.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 07.05.2022.
//

import Foundation
import MapKit

class FavoritesStorage {
    static let shared: FavoritesStorage = FavoritesStorage()
    
    let onAdd = Event<BaseAnnotation>()
    let onRemove = Event<BaseAnnotation>()
    
    private(set) var favorites: [BaseAnnotation] = []
    
    func setup(annotations: [UUID:MKAnnotation]) {
        if let favorites = Storage.value(key: "favoritesID") as? [String?] {
            self.favorites = favorites
                .compactMap({ $0 })
                .compactMap({ UUID(uuidString: $0) })
                .compactMap({ annotations[$0] })
                .compactMap({ $0 as? BaseAnnotation })
        }
    }
    
    func addFavorites(annotation: BaseAnnotation) {
        if !favorites.contains(annotation) {
            favorites.append(annotation)
            onAdd.invoke(data: annotation)
            
            saveFavorites()
        }
    }
    
    func removeFavorites(annotation: BaseAnnotation) {
        let newFavorites = favorites.filter({ $0 != annotation })
        
        if newFavorites.count != favorites.count {
            favorites = newFavorites
            onRemove.invoke(data: annotation)
            
            saveFavorites()
        }
    }
    
    private func saveFavorites() {
        Storage.set(value: favorites.map({ $0.imdfID.uuidString }), forKey: "favoritesID")
    }
}

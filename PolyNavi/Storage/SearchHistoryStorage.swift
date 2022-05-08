//
//  SearchHistoryStorage.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 08.05.2022.
//

import Foundation
import MapKit

class SearchHistoryStorage {
    static let shared = SearchHistoryStorage()
    
    let onHistoryChange = Event<[BaseAnnotation]>()
    
    private(set) var history: [BaseAnnotation] = []
    
    func setup(annotations: [UUID:MKAnnotation]) {
        if let history = Storage.value(key: "histirysID") as? [String?] {
            self.history = history
                .compactMap({ $0 })
                .compactMap({ UUID(uuidString: $0) })
                .compactMap({ annotations[$0] })
                .compactMap({ $0 as? BaseAnnotation })
            
//            self.history = []
        }
    }
    
    func open(annotation: BaseAnnotation) {
        if history.contains(annotation) {
            history = history.filter({ $0 != annotation })
        }
        
        history.insert(annotation, at: 0)
        
        let lastIndex = min(4, history.count - 1)
        
        history = Array(history[0...lastIndex])
        
        onHistoryChange.invoke(data: history)
        Storage.set(value: history.map({ $0.imdfID.uuidString }), forKey: "histirysID")
    }
}

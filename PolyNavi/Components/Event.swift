//
//  Event.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 07.05.2022.
//

import Foundation

class Event<T> {
    
    typealias EventHandler = (T) -> ()
    
    private var eventHandlers = [EventHandler]()
    
    func addHandler(handler: @escaping EventHandler) {
        eventHandlers.append(handler)
    }
    
    func invoke(data: T) {
        for handler in eventHandlers {
            handler(data)
        }
    }
}

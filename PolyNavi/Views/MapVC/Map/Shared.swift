//
//  Shared.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

protocol DetailLevel {
    func detailLevel() -> Int
}

protocol Styleble {
    func configurate(renderer: MKOverlayRenderer)
}

protocol MapRenderer {
    func show(_ mapView: MKMapView)
    func hide(_ mapView: MKMapView)
}

class DetailLevelProcessor<T> {
    
    private struct Size {
        let size: Float
        let state: T
        
        init(size: Float, state: T) {
            self.size = size
            self.state = state
        }
    }
    
    class Builder {
        private let processor: DetailLevelProcessor<T>
        private let levelDetail: Int
        
        init(processor: DetailLevelProcessor<T>, levelDetail: Int) {
            self.processor = processor
            self.levelDetail = levelDetail
        }
        
        @discardableResult
        func add(mapSize: Float, state: T) -> Self {
            processor.add(forDetailLevel: levelDetail, mapSize: mapSize, state: state)
            return self
        }
    }
    
    private var sizes: [Int:[Size]] = [:]
    
    func add(forDetailLevel: Int, mapSize: Float, state: T) {
        let newElement = Size(size: mapSize, state: state)
        
        if var array = sizes[forDetailLevel] {
            array.append(newElement)
            array.sort(by: { $0.size < $1.size })
            sizes[forDetailLevel] = array
        } else {
            sizes[forDetailLevel] = [newElement]
        }
    }
    
    func builder(for detailLevel: Int) -> Builder {
        return Builder(processor: self, levelDetail: detailLevel)
    }
    
    func evaluate(forDetailLevel: Int, mapSize: Float) -> T? {
        
        if let sizes = sizes[forDetailLevel] {
            var lastSize = sizes.first!
            for size in sizes {
                if lastSize.size < mapSize && mapSize < size.size {
                    return lastSize.state
                }
                lastSize = size
            }
            return sizes.first!.state
        }
        
        return nil
    }
}

enum DetailLevelState {
    case big
    case normal
    case min
    case hide
}

let defaultDetailLevelProcessor: DetailLevelProcessor<DetailLevelState> = {
    $0.builder(for: 1)
        .add(mapSize: 17.0, state: .hide)
        .add(mapSize: 19.0, state: .min)
        .add(mapSize: 20.2, state: .normal)
        .add(mapSize: 21.5, state: .big)
    
    $0.builder(for: 2)
        .add(mapSize: 0, state: .hide)
        .add(mapSize: 17, state: .min)
        .add(mapSize: 20, state: .normal)
        .add(mapSize: 22.3, state: .big)
    
    $0.builder(for: 3)
        .add(mapSize: 0, state: .hide)
        .add(mapSize: 19.5, state: .min)
        .add(mapSize: 21.3, state: .normal)
        .add(mapSize: 22.3, state: .big)
    return $0
}(DetailLevelProcessor<DetailLevelState>())

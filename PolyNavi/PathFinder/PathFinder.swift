//
//  PathFinder.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 04.04.2022.
//

import CoreLocation
import MapKit
import GameplayKit

protocol PathResultNode {
    var location: CLLocationCoordinate2D { get }
    var building: Building? { get }
    var level: Level? { get }
}

extension PathResultNode {
    var isIndoor: Bool { building != nil }
}

class PathResult {
    let from: MKAnnotation
    let to: MKAnnotation
    
    let path: [PathResultNode]
    
    let totalCost: Float
    let indoorDistance: Double
    let outdoorDistance: Double
    let fastTime: Float
    let time: Float
    
    var mapRect: MKMapRect {
        let rect = MKMapRect(points: path.map({ MKMapPoint($0.location) }))
        
        return rect
            .union(.init(origin: MKMapPoint(from.coordinate), size: .init(width: 20, height: 20)))
            .union(.init(origin: MKMapPoint(to.coordinate), size: .init(width: 20, height: 20)))
    }
    
    var totalDistance: Double {
        return indoorDistance + outdoorDistance
    }
    
    init(path: [PathResultNode], from: MKAnnotation, to: MKAnnotation, totalCost: Float) {
        self.path = path
        self.from = from
        self.to = to
        self.totalCost = totalCost
        
        indoorDistance = PathResult.indoorDistance(path: path)
        outdoorDistance = PathResult.outdoorDistance(path: path)
        
        time = Float(outdoorDistance / 4.0 + indoorDistance / 2.0) * 3.6
        fastTime = Float(outdoorDistance / 5.0 + indoorDistance / 3.0) * 3.6
    }
    
    static func distance(path: [PathResultNode]) -> Double {
        if path.isEmpty { return 0 }
        
        var result: Double = 0
        for i in 1..<path.count {
            result += path[i].location.distance(from: path[i-1].location)
        }
        
        return result
    }
    
    static func outdoorDistance(path: [PathResultNode]) -> Double {
        PathResult.distance(path: path.filter({ $0.building == nil }))
    }
    
    static func indoorDistance(path: [PathResultNode]) -> Double {
        PathResult.distance(path: path.filter({ $0.building != nil }))
    }
}

class PathNode: GKGraphNode, PathResultNode {
    typealias Cost = Float
    
    var connectedNodes_: [PathNode] = [] {
        didSet {
            self.addConnections(to: connectedNodes_, bidirectional: false)
        }
    }
    
    var location: CLLocationCoordinate2D
    var building: Building?
    var level: Level?
    var weight: Float
    var tags: [IMDF.NavPath.Tag]
    
    private var extraWeight: Float = 0
    
    init(location: CLLocationCoordinate2D, weight: Float, tags: [IMDF.NavPath.Tag]) {
        self.location = location
        self.weight = weight
        self.tags = tags
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func cost(to node: GKGraphNode) -> Float {
        guard let node = node as? PathNode else { return 0}
        
        return Float(node.location.distance(from: location)) * weight + extraWeight
    }
    
    override func estimatedCost(to node: GKGraphNode) -> Float {
        return 0
    }
    
    func applyDenyTags(tags: [IMDF.NavPath.Tag]) {
        extraWeight = self.tags.contains(where: { tags.contains($0) }) ? 1000 : 0
    }
}

class PathFinder {
    static let shared = PathFinder()
    
    var nodes: [PathNode] = []
    var associeted: [(MKAnnotation, PathNode)] = []
    var annotationById: [UUID:MKAnnotation] = [:]
    
    func pathNode(by annotation: MKAnnotation) -> [PathNode] {
        return associeted.filter({ $0.0 === annotation }).map({ $0.1 })
    }
    
    func nearestPathNode(to annotation: MKAnnotation) -> PathNode? {
        return nodes.min(by: { $0.location.distance(from: annotation.coordinate) < $1.location.distance(from: annotation.coordinate) })
    }
    
    func setup(navPath: [IMDF.NavPath], associeted: [IMDF.NavPathAssocieted], buildings: [UUID:Building], levels: [UUID:Level], annotations: [UUID:MKAnnotation]) {
        let converted = navPath.reduce([UUID:(IMDF.NavPath, PathNode)](), { dict, node in
            var dict = dict
            dict[node.identifier] = (node, PathNode(location: (node.geometry.first as! MKPointAnnotation).coordinate,
                                                    weight: node.properties.weight,
                                                    tags: node.properties.tags))
            return dict
        })
        
        converted.forEach({ id, node in
            node.1.connectedNodes_ = node.0.properties.neighbours.compactMap({ converted[$0]?.1 })
            if let builingID = node.0.properties.builing_id,
               let builindg = buildings[builingID] {
                node.1.building = builindg
            }
            
            if let levelID = node.0.properties.level_id,
               let level = levels[levelID] {
                node.1.level = level
            }
        })
        
        self.associeted = associeted
            .filter({ annotations[$0.properties.associeted_id] != nil })
            .map({ (annotations[$0.properties.associeted_id]!, converted[$0.properties.pathNode_id]!.1) })
        self.nodes = converted.values.map({ $0.1 })
        self.annotationById = annotations
        
    }
    
    func findPath(from: MKAnnotation, to: MKAnnotation, denyTags: [IMDF.NavPath.Tag]) -> PathResult? {
        var fromAssociated = pathNode(by: from)
        var toAssociated = pathNode(by: to)
        
        if fromAssociated.isEmpty {
            guard let nearest = nearestPathNode(to: from) else { return nil }
            fromAssociated = [nearest]
        }
        
        if toAssociated.isEmpty {
            guard let nearest = nearestPathNode(to: to) else { return nil }
            toAssociated = [nearest]
        }
        
        
        var shortestPath: [GKGraphNode] = []
        var shortestCost = Float.greatestFiniteMagnitude
        
        nodes.forEach({
            $0.applyDenyTags(tags: denyTags)
        })
        
        for from in fromAssociated {
            for to in toAssociated {
                let path = from.findPath(to: to)
                if path.isEmpty { continue }
                
                let cost = path.cost()
                
                if cost < shortestCost {
                    shortestCost = cost
                    shortestPath = path
                }
            }
        }
        
        return PathResult(path: shortestPath.map({ $0 as! PathNode }), from: from, to: to, totalCost: shortestCost)
    }
}


extension Array where Iterator.Element : GKGraphNode {
    func cost() -> Float {
        if count == 0 { return 0 }
        
        var result: Float = 0
        for i in 1..<count {
            result += self[i-1].cost(to: self[i])
        }
        
        return result
    }
}

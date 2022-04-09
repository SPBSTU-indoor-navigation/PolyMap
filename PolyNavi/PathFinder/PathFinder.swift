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

class PathResult {
    let from: MKAnnotation
    let to: MKAnnotation
    
    let path: [PathResultNode]
    
    let totalCost: Float
    let indoorDistance: Double
    let outdoorDistance: Double
    let fastTime: Float
    let time: Float
    
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
        
        time = Float(outdoorDistance / 5.0 + indoorDistance / 3.0)
        fastTime = Float(outdoorDistance / 6.0 + indoorDistance / 4.0)
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
    
    init(location: CLLocationCoordinate2D) {
        self.location = location
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func cost(to node: GKGraphNode) -> Float {
        guard let node = node as? PathNode else { return 0}
        
        return Float(node.location.distance(from: location))
    }
    
    override func estimatedCost(to node: GKGraphNode) -> Float {
        return cost(to: node)
    }
}

class PathFinder {
    static let shared = PathFinder()
    
    var nodes: [PathNode] = []
    var associeted: [(MKAnnotation, PathNode)] = []
    
    func pathNode(by annotation: MKAnnotation) -> [PathNode] {
        return associeted.filter({ $0.0 === annotation }).map({ $0.1 })
    }
    
    func nearestPathNode(to annotation: MKAnnotation) -> PathNode? {
        return nodes.min(by: { $0.location.distance(from: annotation.coordinate) < $1.location.distance(from: annotation.coordinate) })
    }
    
    func setup(navPath: [IMDF.NavPath], associeted: [IMDF.NavPathAssocieted], buildings: [UUID:Building], levels: [UUID:Level], annotations: [UUID:MKAnnotation]) {
        let converted = navPath.reduce([UUID:(IMDF.NavPath, PathNode)](), { dict, node in
            var dict = dict
            dict[node.identifier] = (node, PathNode(location: (node.geometry.first as! MKPointAnnotation).coordinate))
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
        
        self.associeted = associeted.map({ (annotations[$0.properties.associeted_id]!, converted[$0.properties.pathNode_id]!.1) })
        self.nodes = converted.values.map({ $0.1 })
        
    }
    
    func findPath(from: MKAnnotation, to: MKAnnotation) -> PathResult? {
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
        
        for from in fromAssociated {
            for to in toAssociated {
                let path = from.findPath(to: to)
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
        var result: Float = 0
        for i in 1..<count {
            result += self[i-1].cost(to: self[i])
        }
        
        return result
    }
}

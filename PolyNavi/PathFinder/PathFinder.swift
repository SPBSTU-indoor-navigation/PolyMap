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

final class PathNode: GKGraphNode, PathResultNode {
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
    
    func pathNode(by annotation: MKAnnotation) -> PathNode? {
        return associeted.first(where: { $0.0 === annotation })?.1
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
    
    func findPath(from: MKAnnotation, to: MKAnnotation) -> [PathResultNode] {
        let fromNode = pathNode(by: from) ?? nearestPathNode(to: from)
        let toNode = pathNode(by: to) ?? nearestPathNode(to: to)
        
        guard let fromNode = fromNode,
              let toNode = toNode else { return [] }
        
        return (fromNode.findPath(to: toNode as GKGraphNode)).map({ $0 as! PathNode })
    }
}

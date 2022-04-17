//
//  RouteDetailInfo.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 16.04.2022.
//

import UIKit
import MapKit

class RouteDetailInfo: SectionCollection {
    class PathInfo: Section, CellFor {
        let result: PathResult
        
        override var title: String? { "Информация о маршруте" }
        var content: [(String, String)] = []
        
        override var cellCount: Int { return content.count }
        
        static func timeRound(sec: Float) -> Float {
            return (sec / 60).rounded(.up) * 60
        }
        
        init(result: PathResult) {
            self.result = result
            
            let distance = MKDistanceFormatter()
            let timeFormatter = DateComponentsFormatter()
            timeFormatter.unitsStyle = .full
            timeFormatter.allowedUnits = [ .minute ]
            
            content = []
            
            content.append((L10n.MapInfo.Route.Info.distance, distance.string(for: result.totalDistance) ?? "0"))
            let time = timeFormatter.string(from: TimeInterval(max(60, PathInfo.timeRound(sec: result.time)))) ?? "0"
            let fastTime = timeFormatter.string(from: TimeInterval(max(60, PathInfo.timeRound(sec: result.fastTime)))) ?? "0"
            
            content.append((L10n.MapInfo.Route.Info.time, time))
            if time != fastTime { content.append((L10n.MapInfo.Route.Info.fastTime, fastTime)) }
            if result.indoorDistance > 0 && result.outdoorDistance > 0 {
                content.append((L10n.MapInfo.Route.Info.indoor, distance.string(for: result.indoorDistance) ?? "0"))
                content.append((L10n.MapInfo.Route.Info.outdoor, distance.string(for: result.outdoorDistance) ?? "0"))
            }
        }
        
        func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifire) as! DetailCell
            
            cell.configurate(title: content[indexPath.row].0, content: content[indexPath.row].1, isSelectable: false)
            
            return cell
        }
    }
    
    class Settings: Section, CellFor {
        override var title: String? { L10n.MapInfo.Route.Info.parameters }
        override var cellCount: Int { 2 }
        
        var asphalt: ((Bool)->Void)?, serviceRoute: ((Bool)->Void)?
        
        init(asphalt: ((Bool)->Void)?, serviceRoute: ((Bool)->Void)?) {
            self.asphalt = asphalt
            self.serviceRoute = serviceRoute
        }
        
        func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: ToggleCell.identifire) as! ToggleCell
            
            if indexPath.row == 0 {
                cell.configurate(title: L10n.MapInfo.Route.Info.asphalt, onToggle: asphalt)
            } else {
                cell.configurate(title: L10n.MapInfo.Route.Info.serviceRoute, onToggle: serviceRoute)
            }
            
            return cell
        }
    }
    
    var redrawPath: (() -> Void)?
    var asphalt: Bool {
        didSet {
            redrawPath?()
        }
    }
    var serviceRoute: Bool {
        didSet {
            redrawPath?()
        }
    }
    
    init(result: PathResult?, redrawPath: (() -> Void)?, asphalt: Bool, serviceRoute: Bool) {
        self.asphalt = asphalt
        self.serviceRoute = serviceRoute
        self.redrawPath = redrawPath
        
        super.init()
        
        sections = []
        
        if let result = result {
            sections.append(PathInfo(result: result))
        }
        sections.append(Settings(asphalt: { self.asphalt = $0 }, serviceRoute: { self.serviceRoute = $0 }))
        sections.append(Report(favorite: false, report: true))
    }
}

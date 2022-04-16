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
    
    
    init(result: PathResult?) {
        super.init()
        
        sections = []
        
        if let result = result {
            sections.append(PathInfo(result: result))
        }
        
        sections.append(Report(favorite: false, report: true))
    }
}

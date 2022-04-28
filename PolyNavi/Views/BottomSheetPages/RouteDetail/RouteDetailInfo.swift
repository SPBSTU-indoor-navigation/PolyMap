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
        
        override var title: String? { L10n.MapInfo.Route.Info.routeInformation }
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
    
    class Settings: Section, CellFor, SelectRowFor {
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
        
        func didSelect(_ tableView: UITableView, _ indexPath: IndexPath) {
            if let toggle = tableView.cellForRow(at: indexPath) as? ToggleCell {
                toggle.toggleSwitch()
            }
        }
    }
    
    static func register(tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableView.UITableViewCellIdentifire)
        tableView.register(DetailCell.self, forCellReuseIdentifier: DetailCell.identifire)
        tableView.register(ToggleCell.self, forCellReuseIdentifier: ToggleCell.identifire)
        tableView.register(SimpleShareCell.self, forCellReuseIdentifier: SimpleShareCell.identifire)
        tableView.register(ShareAppClip.self, forCellReuseIdentifier: ShareAppClip.identifire)
        tableView.register(SearchGroupedHeaderView.self, forHeaderFooterViewReuseIdentifier: SearchGroupedHeaderView.identifier)
    }
    
    var redrawPath: (() -> Void)?
    var asphalt: Bool = false {
        didSet {
            redrawPath?()
        }
    }
    var serviceRoute: Bool = false {
        didSet {
            redrawPath?()
        }
    }
    
    init(result: PathResult?, redrawPath: (() -> Void)?, asphalt: Bool, serviceRoute: Bool) {
        self.asphalt = asphalt
        self.serviceRoute = serviceRoute
        self.redrawPath = redrawPath
        
        super.init()
        configurate(result: result, tableView: nil)
    }
    
    func configurate(result: PathResult?, tableView: UITableView?) {
        sections = []
        
        if let result = result {
            sections.append(PathInfo(result: result))
        }
        sections.append(Settings(asphalt: { self.asphalt = $0 }, serviceRoute: { self.serviceRoute = $0 }))
        if let result = result,
           let from = result.from as? (BaseAnnotation & Searchable),
           let to = result.to as? (BaseAnnotation & Searchable) {
            sections.append(Share(from: from, to: to))
        }
        
        sections.append(Report(favorite: false, report: true))
        
        tableView?.reloadSections(IndexSet(0...0), with: .none)
    }
    
    override init() {
        super.init()
    }
    
    override func delegateTV(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = self.section(for: section)?.title else { return nil }
        
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchGroupedHeaderView.identifier) as? SearchGroupedHeaderView else { return nil}
        
        header.configurate(text: title)
        
        return header
    }

}

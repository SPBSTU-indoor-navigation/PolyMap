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
        
        var asphalt, serviceRoute: CustomBinding<Bool>
        
        init(asphalt: CustomBinding<Bool>, serviceRoute: CustomBinding<Bool>) {
            self.asphalt = asphalt
            self.serviceRoute = serviceRoute
        }
        
        func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: ToggleCell.identifire) as! ToggleCell
            
            if indexPath.row == 0 {
                cell.configurate(title: L10n.MapInfo.Route.Info.asphalt, value: asphalt.get(), onToggle: asphalt.set)
            } else {
                cell.configurate(title: L10n.MapInfo.Route.Info.serviceRoute, value: serviceRoute.get(), onToggle: serviceRoute.set)
            }
            
            return cell
        }
        
        func didSelect(_ tableView: UITableView, _ indexPath: IndexPath) {
            if let toggle = tableView.cellForRow(at: indexPath) as? ToggleCell {
                toggle.toggleSwitch()
            }
        }
    }
    
    class RouteShare: Section, CellFor, SelectRowFor {
        override var cellCount: Int { 2 }
        
        var from: BaseAnnotation & Searchable
        var to: BaseAnnotation & Searchable
        var asphalt: Bool
        var serviceRoute: Bool
        
        init(from: BaseAnnotation & Searchable, to: BaseAnnotation & Searchable, asphalt: Bool, serviceRoute: Bool) {
            self.from = from
            self.to = to
            self.asphalt = asphalt
            self.serviceRoute = serviceRoute
        }
        
        func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: SimpleShareCell.identifire, for: indexPath) as! SimpleShareCell
                
                cell.configurate()
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: ShareAppClip.identifire, for: indexPath) as! ShareAppClip
                
                cell.configurate()
                
                return cell
            }
        }
        
        func didSelect(_ tableView: UITableView, _ indexPath: IndexPath) {
            if indexPath.row == 0 {
                
                let textToShare = [ "text" ]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)?.accessoryView
                
                if let vc = tableView.delegate as? UIViewController {
                    vc.present(activityViewController, animated: true, completion: nil)
                }
                
            } else {
                if let vc = tableView.delegate as? UIViewController {
                    ShareDialog(from: from, to: to, asphalt: asphalt, serviceRoute: serviceRoute).present(to: vc, animated: true, completion: nil)
                }
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
            share?.asphalt = asphalt
        }
    }
    var serviceRoute: Bool = false {
        didSet {
            redrawPath?()
            share?.serviceRoute = serviceRoute
        }
    }
    var share: RouteShare?
    
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
        sections.append(Settings(asphalt: .init(get: { self.asphalt }, set: { self.asphalt = $0 }),
                                 serviceRoute: .init(get: { self.serviceRoute }, set: { self.serviceRoute = $0 })))
        if let result = result,
           let from = result.from as? (BaseAnnotation & Searchable),
           let to = result.to as? (BaseAnnotation & Searchable) {
            let section = RouteShare(from: from, to: to, asphalt: asphalt, serviceRoute: serviceRoute)
            share = section
            sections.append(section)
        } else {
            share = nil
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

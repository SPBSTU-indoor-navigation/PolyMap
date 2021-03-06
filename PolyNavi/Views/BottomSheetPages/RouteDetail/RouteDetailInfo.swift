//
//  RouteDetailInfo.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 16.04.2022.
//

import UIKit
import MapKit

class RouteParameters: Equatable {
    static func == (lhs: RouteParameters, rhs: RouteParameters) -> Bool {
        return lhs.asphalt == rhs.asphalt && lhs.serviceRoute == rhs.serviceRoute
    }
    
    enum Constants {
        static let storageAsphalt = "storageAsphalt"
        static let storageServiceRoute = "storageServiceRoute"
    }
    
    static var fromStorage: RouteParameters {
        .init(asphalt: (Storage.value(key: Constants.storageAsphalt) as? Bool) ?? true,
              serviceRoute: (Storage.value(key: Constants.storageServiceRoute) as? Bool) ?? false)
    }
    
    var asphalt: Bool
    var serviceRoute: Bool
    
    init(asphalt: Bool, serviceRoute: Bool) {
        self.asphalt = asphalt
        self.serviceRoute = serviceRoute
    }
    
    var denyTags: [IMDF.NavPath.Tag] {
        var result: [IMDF.NavPath.Tag] = []
        
        if asphalt { result.append(.dirt) }
        if !serviceRoute { result.append(.service) }
        
        return result
    }
    
    func saveToStorage() {
        Storage.set(value: asphalt, forKey: Constants.storageAsphalt)
        Storage.set(value: serviceRoute, forKey: Constants.storageServiceRoute)
    }
}

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
        var routeParameters: RouteParameters

        
        init(from: BaseAnnotation & Searchable, to: BaseAnnotation & Searchable, params: RouteParameters) {
            self.from = from
            self.to = to
            self.routeParameters = params
        }
        
        func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: SimpleShareCell.identifire, for: indexPath) as! SimpleShareCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: ShareAppClip.identifire, for: indexPath) as! ShareAppClip
                
                cell.configurate()
                
                return cell
            }
        }
        
        func didSelect(_ tableView: UITableView, _ indexPath: IndexPath) {
            if indexPath.row == 0 {
                
                let textToShare = [ CodeGeneratorProvider.createPermalink(from: from.imdfID, to: to.imdfID, params: routeParameters) ]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                guard let cell = tableView.cellForRow(at: indexPath) as? SimpleShareCell else { return }
                
                activityViewController.popoverPresentationController?.sourceView = cell.image
                if let vc = tableView.delegate as? UIViewController {
                    vc.present(activityViewController, animated: true, completion: nil)
                }
                
            } else {
                if let vc = tableView.delegate as? UIViewController {
                    ShareDialog(from: from, to: to, routeParams: routeParameters).present(to: vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    static func register(tableView: UITableView) {
        tableView.register(DetailCell.self, forCellReuseIdentifier: DetailCell.identifire)
        tableView.register(ToggleCell.self, forCellReuseIdentifier: ToggleCell.identifire)
        tableView.register(SimpleShareCell.self, forCellReuseIdentifier: SimpleShareCell.identifire)
        tableView.register(ShareAppClip.self, forCellReuseIdentifier: ShareAppClip.identifire)
        tableView.register(SearchGroupedHeaderView.self, forHeaderFooterViewReuseIdentifier: SearchGroupedHeaderView.identifier)
    }
    
    var redrawPath: (() -> Void)?
    var routeParams: RouteParameters = .init(asphalt: false, serviceRoute: false)
    
    func onParamsUpdate() {
        routeParams.saveToStorage()
        redrawPath?()
    }
    
    init(result: PathResult?, redrawPath: (() -> Void)?, routeParams: RouteParameters) {
        self.routeParams = routeParams
        self.redrawPath = redrawPath
        
        super.init()
        configurate(result: result, tableView: nil)
    }
    
    func configurate(result: PathResult?, tableView: UITableView?) {
        sections = []
        
        if let result = result {
            sections.append(PathInfo(result: result))
        }
        
        sections.append(Settings(asphalt: .init(get: { self.routeParams.asphalt }, set: { self.routeParams.asphalt = $0; self.onParamsUpdate() }),
                                 serviceRoute: .init(get: { self.routeParams.serviceRoute }, set: { self.routeParams.serviceRoute = $0; self.onParamsUpdate() })))
        if let result = result,
           let from = result.from as? (BaseAnnotation & Searchable),
           let to = result.to as? (BaseAnnotation & Searchable) {
            let section = RouteShare(from: from, to: to, params: self.routeParams)
            sections.append(section)
            
            
            sections.append(Report(report: SectionCollection.Report.ReportRoute(from: from, to: to, params: self.routeParams)))
        }
        
    
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

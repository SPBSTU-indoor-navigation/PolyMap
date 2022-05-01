//
//  ExclusiveRouteDetailInfo.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 28.04.2022.
//

import UIKit

class ExclusiveRouteDetailInfo: RouteDetailInfo {
    
    class Close: Section, CellFor, SelectRowFor {
        override var cellCount: Int { 1 }
        
        var onClose: (()->Void)?
        
        init(onClose: (()->Void)?) {
            self.onClose = onClose
        }
        
        func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: ExclusiveCloseCell.identifire) as! ExclusiveCloseCell
            
            cell.configurate(title: L10n.MapInfo.ExclRoute.Info.close)
            
            return cell
        }
        
        func didSelect(_ tableView: UITableView, _ indexPath: IndexPath) {
            onClose?()
        }
    }
    
    class FromTo: Section, CellFor {
        override var cellCount: Int { 2 }
        var from, to: Searchable
        
        init(from: Searchable, to: Searchable) {
            self.from = from
            self.to = to
        }
        
        func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: ExclusiveSearchableCell.identifire) as! ExclusiveSearchableCell
            
            let isFrom = indexPath.row == 0
            
            cell.configurate(searchable: isFrom ? from : to, title: isFrom ? L10n.MapInfo.Route.Info.from : L10n.MapInfo.Route.Info.to)
            
            return cell
        }
    }
    

    var allowParameterChange: Bool
    var onExclusiveClose: () -> Void
    init(result: PathResult, asphalt: Bool, serviceRoute: Bool, allowParameterChange: Bool, redrawPath: (() -> Void)?, onExclusiveClose: @escaping () -> Void) {
        self.allowParameterChange = allowParameterChange
        self.onExclusiveClose = onExclusiveClose
        
        super.init()
        
        self.asphalt = asphalt
        self.serviceRoute = serviceRoute
        self.redrawPath = redrawPath
        
        configurate(result: result, tableView: nil)
    }
    
    override func configurate(result: PathResult?, tableView: UITableView?) {
        sections = []
        
        if let result = result {
            if let from = result.from as? Searchable,
               let to = result.to as? Searchable {
                sections.append(FromTo(from: from, to: to))
            }
            sections.append(PathInfo(result: result))
        }
        
        if allowParameterChange {
            sections.append(Settings(asphalt: .init(get: { self.asphalt }, set: { self.asphalt = $0 }),
                                     serviceRoute: .init(get: { self.serviceRoute }, set: { self.serviceRoute = $0 })))
        }
        
        sections.append(Close(onClose: onExclusiveClose))
    }
}

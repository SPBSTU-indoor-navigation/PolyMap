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
            
            cell.configurate(title: "Завершить эксклюзивный режим")
            
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
            
            cell.configurate(searchable: isFrom ? from : to, title: isFrom ? "from:" : "to:")
            
            return cell
        }
    }
    

    init(result: PathResult, onExclusiveClose: @escaping () -> Void) {
        super.init()
        
        sections = []
        sections.append(FromTo(from: result.from as! Searchable, to: result.to as! Searchable))
        sections.append(PathInfo(result: result))
        sections.append(Close(onClose: onExclusiveClose))
    }
}

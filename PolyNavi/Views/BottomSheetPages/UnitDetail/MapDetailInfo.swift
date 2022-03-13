//
//  MapDetailInfo.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 07.03.2022.
//
import UIKit

protocol CellFor {
    func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell
}

class MapDetailInfo {
    var title: String = ""
    var sections: [Section] = []
    
    
    class Section {
        var title: String? { return nil }
        var cellCount: Int { return 1 }
    }
    
    class Route: Section, CellFor {
        var showRoute = true
        var showIndoor = true
        
        var buildingID: UUID?
        
        init(showRoute: Bool = true, showIndoor: Bool = true) {
            self.showRoute = showRoute
            self.showIndoor = showIndoor
        }
        
        func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: RouteInfoCell.identifire, for: indexPath) as! RouteInfoCell
            cell.configutate(showRoute: showRoute, showIndoor: showIndoor, buildingID: buildingID)
            cell.selectionStyle = .none
            return cell
        }
        
        func with(buildingID: UUID) -> Self {
            self.buildingID = buildingID
            return self
        }
    }
    
    class Detail: Section, CellFor  {
        var content: [(String, String)] = []
        
        override var title: String? { return "Detail" }
        override var cellCount: Int {
            return content.count
        }
        
        init(phone: String? = nil, email: String? = nil, website: String? = nil, address: String? = nil) {
            if let phone = phone { content.append((L10n.MapInfo.Detail.phone, phone)) }
            if let email = email { content.append((L10n.MapInfo.Detail.email, email)) }
            if let website = website { content.append((L10n.MapInfo.Detail.website, website)) }
            if let address = address { content.append((L10n.MapInfo.Detail.address, address)) }
        }
        
        func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier) as! DetailCell
            
            cell.configurate(title: content[indexPath.row].0, content: content[indexPath.row].1)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    class Report: Section, CellFor {
        var favorite: Bool = true
        var report: Bool = true
        
        override var cellCount: Int { return favorite.intValue + report.intValue }
        
        init(favorite: Bool = true, report: Bool = true) {
            self.favorite = favorite
            self.report = report
        }
        
        func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
            
            let image = UIImage(systemName: favorite && indexPath.row == 0 ? "star.fill" : "exclamationmark.bubble.fill")
            let text = favorite && indexPath.row == 0 ? L10n.MapInfo.Report.favorites : L10n.MapInfo.Report.issue
            
            if #available(iOS 14.0, *) {
                var content = cell.defaultContentConfiguration()
                content.image = image
                content.text = text
                cell.contentConfiguration = content
            } else {
                cell.textLabel?.text = text
                cell.imageView?.image = image
            }
            
            cell.backgroundColor = Asset.Colors.bottomSheetGroupped.color
            cell.selectionStyle = .gray
            return cell
        }
    }
    
    func section(for row: Int, title: Bool) -> Section? {
        return sections[row - title.intValue]
    }
    
}

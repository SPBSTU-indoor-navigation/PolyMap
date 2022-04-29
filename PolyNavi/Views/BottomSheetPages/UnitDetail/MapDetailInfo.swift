//
//  MapDetailInfo.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 07.03.2022.
//
import UIKit
import MapKit

class MapDetailInfo: SectionCollection {
    var title: String = ""
    var annotation: MKAnnotation?

    class Route: Section, CellFor {
        var showRoute = true
        var showIndoor = true
        var annotation: MKAnnotation?
        
        var buildingID: UUID?
        
        init(showRoute: Bool = true, showIndoor: Bool = true, annotation: MKAnnotation? = nil) {
            self.showRoute = showRoute
            self.showIndoor = showIndoor
            self.annotation = annotation
        }
        
        func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: RouteInfoCell.identifire, for: indexPath) as! RouteInfoCell
            
            var variant: RouteInfoCell.RouteVariant = .to
            
            if let to = RouteDetailVC.toPoint, let from = RouteDetailVC.fromPoint {
                if from === annotation { variant = .from }
                else if to === annotation { variant = .to }
                else { variant = .fromTo }
            } else if let to = RouteDetailVC.toPoint {
                if to === annotation { variant = .to }
            } else if let from = RouteDetailVC.fromPoint {
                if from === annotation { variant = .from }
            }
            
            
            cell.configutate(routeVariant: variant, showIndoor: showIndoor, buildingID: buildingID)
            cell.selectionStyle = .none
            cell.onRouteClick = { variant in
                if let annotation = self.annotation {
                    if variant == .to {
                        MapInfo.routeDetail?.setTo(annotation)
                    } else {
                        MapInfo.routeDetail?.setFrom(annotation)
                    }
                }
            }
            cell.onBuildingClick = { print("BUILDING") }
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
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifire) as! DetailCell
            
            cell.configurate(title: content[indexPath.row].0, content: content[indexPath.row].1)
            return cell
        }
    }
    
    func section(for row: Int, title: Bool) -> Section? {
        sections[safe: row - title.intValue]
    }
}

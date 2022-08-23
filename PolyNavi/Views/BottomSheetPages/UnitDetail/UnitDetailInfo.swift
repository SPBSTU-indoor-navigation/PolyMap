//
//  UnitDetailInfo.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 07.03.2022.
//
import UIKit
import MapKit

class UnitDetailInfo: SectionCollection {
    var title: String = ""
    var annotation: BaseAnnotation?
    weak var unitDetail: UnitDetailVC?

    class Route: Section, CellFor {
        var showRoute = true
        var showIndoor = true
        var annotation: MKAnnotation?
        
        var building: Building? {
            if let annotation = annotation as? AttractionAnnotation {
                return annotation.building
            }
            return nil
        }
        weak var unitDetail: UnitDetailVC?
        
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
            
            
            cell.configutate(routeVariant: variant, showIndoor: showIndoor)
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
            cell.onBuildingClick = { [weak self] in
                guard let self = self else { return }
                
                if self.building?.levels.isEmpty ?? true {
                    if let vc = tableView.delegate as? UIViewController {  
                        EmptyBuildingPlan(buildingName: (self.annotation as? Searchable)?.mainTitle ?? "-").present(to: vc, animated: true)
                    }
                } else {
                    if let attraction = self.annotation as? AttractionAnnotation {
                        self.unitDetail?.buildingPlanOpen(attraction: attraction)
                    }
                }
                
            }
            return cell
        }
    }
    
    class Detail: Section, CellFor  {
        var content: [(String, String)] = []
        
        override var title: String? { return L10n.MapInfo.Detail.title }
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
    
    init(castable: UnitDetailInfoCastable, unitDetail: UnitDetailVC) {
        super.init()
        self.unitDetail = unitDetail
        castable.cast(unitDetailInfo: self)
        
        for section in sections {
            if let route = section as? Route {
                route.unitDetail = unitDetail
            }
        }
    }
}

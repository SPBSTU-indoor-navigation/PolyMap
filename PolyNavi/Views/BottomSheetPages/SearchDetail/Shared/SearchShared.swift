//
//  SearchShared.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 27.03.2022.
//

import UIKit

protocol SearchableConfigurate {
    func configurate(searchable: Searchable)
}

class SearchShared {
    static func registerCells(tableView: UITableView) {
        tableView.register(OccupantSearchCell.self, forCellReuseIdentifier: OccupantAnnotation.identifier)
        tableView.register(AttractionSearchCell.self, forCellReuseIdentifier: AttractionAnnotation.identifier)
        tableView.register(AmenitySearchCell.self, forCellReuseIdentifier: AmenityAnnotation.identifier)
        tableView.register(EnviromentAmenitySearchCell.self, forCellReuseIdentifier: EnviromentAmenityAnnotation.identifier)
        tableView.register(SearchHeaderView.self, forHeaderFooterViewReuseIdentifier: SearchHeaderView.identifier)
    }
    
    static func createIcon(for searchable: Searchable) -> UIView? {
        let icon: UIView?
        
        switch searchable {
        case is OccupantAnnotation:
            icon = OccupantSearchIcon()
        case is AttractionAnnotation:
            icon = AttractionSearchIcon()
        case is AmenityAnnotation:
            icon = AmenitySearchIcon()
        case is EnviromentAmenityAnnotation:
            icon = AmenitySearchIcon()
        default:
            icon = nil
        }
        
        if let icon = icon as? SearchableConfigurate {
            icon.configurate(searchable: searchable)
        }
        
        return icon
    }
    
    static func createCell(for searchable: Searchable) -> BaseSearchCell? {
        let cell: BaseSearchCell?
        switch searchable {
        case is OccupantAnnotation:
            cell = OccupantSearchCell(style: .default, reuseIdentifier: "")
        case is AttractionAnnotation:
            cell = AttractionSearchCell(style: .default, reuseIdentifier: "")
        case is AmenityAnnotation:
            cell = AmenitySearchCell(style: .default, reuseIdentifier: "")
        case is EnviromentAmenityAnnotation:
            cell = EnviromentAmenitySearchCell(style: .default, reuseIdentifier: "")
        default:
            cell = nil
        }
        
        if let cell = cell {
            cell.configurate(searchable: searchable)
        }
        
        return cell
    }
    
    static func cell(_ tableView: UITableView, for searchable: Searchable, indexPath: IndexPath, grouped: Bool = false) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: (searchable as? ReusableCell)?.identifier ?? OccupantAnnotation.identifier, for: indexPath)
        
        (cell as? BaseSearchCell)?.configurate(searchable: searchable)
        
        cell.backgroundColor = grouped ? Asset.Colors.bottomSheetGroupped.color : .clear
        
        if let cell = cell as? BaseSearchCell {
            cell.separatorColor = grouped ? .clear : .separator
        }
        
        return cell
    }
    
    static func header(_ tableView: UITableView, for section: Int, title: String, grouped: Bool = false) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchHeaderView.identifier) as? SearchHeaderView else { return nil}
        
        header.configurate(text: title)
        
        return header
    }
}

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
        tableView.register(SearchHeaderView.self, forHeaderFooterViewReuseIdentifier: SearchHeaderView.identifier)
    }
    
    static func cell(_ tableView: UITableView, for searchable: Searchable, indexPath: IndexPath, grouped: Bool = false) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: (searchable as? ReusableCell)?.identifier ?? OccupantAnnotation.identifier, for: indexPath)
        
        if searchable is OccupantAnnotation {
            (cell as? OccupantSearchCell)?.configurate(searchable: searchable)
        } else if searchable is AttractionAnnotation {
            (cell as? AttractionSearchCell)?.configurate(searchable: searchable)
        }
        
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

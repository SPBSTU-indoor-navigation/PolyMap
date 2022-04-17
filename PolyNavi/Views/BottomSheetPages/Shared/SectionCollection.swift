//
//  SectionCollection.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 16.04.2022.
//

import UIKit

protocol CellFor {
    func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell
}

class SectionCollection {
    class Section {
        var title: String? { return nil }
        var cellCount: Int { return 1 }
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableView.UITableViewCellIdentifire, for: indexPath)
            
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
    
    
    var sections: [Section] = []
    
    func section(for row: Int) -> Section? {
        return sections[row]
    }
}

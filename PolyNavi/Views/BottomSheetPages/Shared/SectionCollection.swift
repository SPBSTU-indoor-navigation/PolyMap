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

protocol SelectRowFor {
    func didSelect(_ tableView: UITableView, _ indexPath: IndexPath)
}

class SectionCollection: NSObject, UITableViewDataSource {
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
            return cell
        }
    }
    
    class Share: Section, CellFor, SelectRowFor {
        override var cellCount: Int { 1 + (to != nil).intValue }
        
        var from: BaseAnnotation & Searchable
        var to: (BaseAnnotation & Searchable)?
        
        init(from: (BaseAnnotation & Searchable), to: (BaseAnnotation & Searchable)? = nil) {
            self.from = from
            self.to = to
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
                if let vc = tableView.delegate as? UIViewController,
                   let to = to {
                    ShareDialog(from: from, to: to).present(to: vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    var sections: [Section] = []
    
    func section(for row: Int) -> Section? {
        return sections[row]
    }
    
    
    //Delegate
    func delegateTV(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let section = section(for: indexPath.section)
        {
            (section as? SelectRowFor)?.didSelect(tableView, indexPath)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func delegateTV(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    //DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let section = section(for: indexPath.section),
           let cellFor = section as? CellFor {
            return cellFor.cellFor(tableView, indexPath)
        }
        
        return UITableViewCell()
    }
}

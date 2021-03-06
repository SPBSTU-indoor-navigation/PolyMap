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
    
    class Report: Section, CellFor, SelectRowFor {
        class ReportBase { }
        class ReportAnnotation: ReportBase {
            let annotation: BaseAnnotation & Searchable
            
            init(annotation: BaseAnnotation & Searchable) {
                self.annotation = annotation
            }
        }
        
        class ReportRoute: ReportBase {
            let from: BaseAnnotation & Searchable
            let to: BaseAnnotation & Searchable
            let params: RouteParameters
            
            init(from: BaseAnnotation & Searchable, to: BaseAnnotation & Searchable, params: RouteParameters) {
                self.from = from
                self.to = to
                self.params = params
            }
        }
        
        var favorite: BaseAnnotation? = nil
        var report: ReportBase? = nil
        
        override var cellCount: Int { return (favorite != nil).intValue + (report != nil).intValue }
        
        init(favorite: BaseAnnotation? = nil, report: ReportBase? = nil) {
            self.favorite = favorite
            self.report = report
            
            super.init()
        }
        
        func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            
            if let favorite = favorite, indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.identifire, for: indexPath) as! FavoriteCell
                cell.configurate(isFavorite: FavoritesStorage.shared.favorites.contains(favorite), animated: false)
                return cell
            } else {
                let cell = UITableViewCell()
                
                let image = UIImage(systemName: "exclamationmark.bubble.fill")
                let text = L10n.MapInfo.Report.issue
                
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
        
        func didSelect(_ tableView: UITableView, _ indexPath: IndexPath) {
            if let favorite = favorite, indexPath.row == 0 {
                if FavoritesStorage.shared.favorites.contains(favorite) {
                    FavoritesStorage.shared.removeFavorites(annotation: favorite)
                    if let cell = tableView.cellForRow(at: indexPath) as? FavoriteCell {
                        cell.configurate(isFavorite: false, animated: true)
                    }
                } else {
                    FavoritesStorage.shared.addFavorites(annotation: favorite)
                    if let cell = tableView.cellForRow(at: indexPath) as? FavoriteCell {
                        cell.configurate(isFavorite: true, animated: true)
                    }
                }
            } else {
                if let vc = tableView.delegate as? UIViewController,
                   let report = report {
                    ReportanIssue(report: report).present(to: vc, animated: true)
                }
            }
        }
        
    }
    
    class Share: Section, CellFor, SelectRowFor {
        override var cellCount: Int { 1 }
        
        var annotation: BaseAnnotation & Searchable
        
        init(annotation: BaseAnnotation & Searchable) {
            self.annotation = annotation
        }
        
        func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: SimpleShareCell.identifire, for: indexPath) as! SimpleShareCell
            return cell
        }
        
        func didSelect(_ tableView: UITableView, _ indexPath: IndexPath) {
            let textToShare = [ CodeGeneratorProvider.createPermalink(annotation: annotation.imdfID) ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            guard let cell = tableView.cellForRow(at: indexPath) as? SimpleShareCell else { return }
            
            activityViewController.popoverPresentationController?.sourceView = cell.image
            if let vc = tableView.delegate as? UIViewController {
                vc.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    var sections: [Section] = []
    
    func section(for row: Int) -> Section? {
        return sections[safe: row]
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

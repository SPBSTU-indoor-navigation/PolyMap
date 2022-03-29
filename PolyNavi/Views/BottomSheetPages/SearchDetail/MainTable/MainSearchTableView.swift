//
//  MainSearchTableView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 26.03.2022.
//

import UIKit

protocol MainSearchTableViewDelegate {
    func mainSearchTableWillBeginDragging(_ scrollView: UIScrollView);
    func mainSearchTableDidScroll(_ scrollView: UIScrollView);
    func mainSearchTableWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    func mainSearchTable(didSelect searchable: Searchable)
}

class MainSearchTableView: UITableView {
    var mainSearchTableViewDelegate: MainSearchTableViewDelegate?
    var searchable: [Searchable] = [] {
        didSet {
            data.process(searchable: searchable)
            reloadData()
        }
    }
    
    private var data: MainSearchData = MainSearchData()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        translatesAutoresizingMaskIntoConstraints = false
        dataSource = data
        delegate = self
            
        SearchShared.registerCells(tableView: self)
        register(SearchGroupedHeaderView.self, forHeaderFooterViewReuseIdentifier: SearchGroupedHeaderView.identifier)
        register(TodayTableViewCell.self, forCellReuseIdentifier: TodayTableViewCell.identifier)

        estimatedSectionFooterHeight = 0
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainSearchTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = data.titleForHeaderInSection(section: section) else { return nil }
        
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchGroupedHeaderView.identifier) as? SearchGroupedHeaderView else { return nil}
        
        header.configurate(text: title)
        
        return header
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        mainSearchTableViewDelegate?.mainSearchTableWillBeginDragging(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        mainSearchTableViewDelegate?.mainSearchTableDidScroll(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        mainSearchTableViewDelegate?.mainSearchTableWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let searchable = data.searchable(for: indexPath) {
            mainSearchTableViewDelegate?.mainSearchTable(didSelect: searchable)
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if data.searchable(for: indexPath) != nil {
            return indexPath
        }
        
        return nil
    }
}


class MainSearchData: NSObject {
    
    enum SectionType {
        case today
        case favorites
        case recent
        
        var sectionName: String? {
            switch self {
            case .today: return L10n.MapInfo.Search.today
            case .favorites: return L10n.MapInfo.Search.favorites
            case .recent: return L10n.MapInfo.Search.recent
            }
        }
    }
    
    class TodayData {
        var searchable: Searchable
        var progress: CGFloat
        
        init(searchable: Searchable) {
            self.searchable = searchable
            progress = 0.4
        }
    }
    
    var today: (SectionType, [TodayData]) = (.today, [])
    var favorites: (SectionType, [Searchable]) = (.favorites,[])
    var recent: (SectionType, [Searchable]) = (.recent,[])
    
    private var compute: [(SectionType, [Any])] = []
    
    func process(searchable: [Searchable]) {
        recent.1 = Array(searchable[2...4])
        favorites.1 = Array(searchable[52...55])
        today.1 = Array(searchable[12...15]).map({ TodayData(searchable: $0) })
        
        reload()
    }
    
    func searchable(for indexPath: IndexPath) -> Searchable? {
        if let searchable = compute[indexPath.section].1[indexPath.row] as? Searchable {
            return searchable
        }
        
        return nil
    }
    
    func reload() {
        compute = [today as (SectionType, [Any]), recent, favorites].filter({ !$0.1.isEmpty })
    }
}

extension MainSearchData: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return compute.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = compute[section]
        
        if section.1 is [TodayData] {
            return 1
        }
        
        return section.1.count
    }
    
    func titleForHeaderInSection(section: Int) -> String? {
        return compute[section].0.sectionName
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = compute[indexPath.section]
        
        if section.0 == .today {
            
            let t = tableView.dequeueReusableCell(withIdentifier: TodayTableViewCell.identifier, for: indexPath) as! TodayTableViewCell
            t.configurate(tableView: tableView)
            return t
        }
        
        if let searchable = searchable(for: indexPath) {
            return SearchShared.cell(tableView, for: searchable, indexPath: indexPath, grouped: true)
        }
        
        return UITableViewCell()
    
    }
}

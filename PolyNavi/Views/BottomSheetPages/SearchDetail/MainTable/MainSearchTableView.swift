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
    
    private var data: MainSearchData!
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        data = MainSearchData(tableView: self)
        translatesAutoresizingMaskIntoConstraints = false
        dataSource = data
        delegate = self
        
        SearchShared.registerCells(tableView: self)
        register(SearchGroupedHeaderView.self, forHeaderFooterViewReuseIdentifier: SearchGroupedHeaderView.identifier)
        register(TodayCellAttraction.self, forCellReuseIdentifier: TodayCellAttraction.identifier)
        register(TodayCellOccupant.self, forCellReuseIdentifier: TodayCellOccupant.identifier)

        estimatedSectionHeaderHeight = 33
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
        case recomendation
        
        var sectionName: String? {
            switch self {
            case .today: return L10n.MapInfo.Search.today
            case .favorites: return L10n.MapInfo.Search.favorites
            case .recent: return L10n.MapInfo.Search.recent
            case .recomendation: return L10n.MapInfo.Search.recomendation
            }
        }
    }
    
    var today: (SectionType, [TodayCellModel]) = (.today, [])
    var favorites: (SectionType, [Searchable]) = (.favorites,[])
    var recent: (SectionType, [Searchable]) = (.recent,[])
    var recomendation: (SectionType, [Searchable]) = (.recomendation,[])
    
    weak var tableView: UITableView?
    
    private var compute: [(SectionType, [Any])] = []
    
    func process(searchable: [Searchable]) {
        recent.1 = SearchHistoryStorage.shared.history.compactMap({ $0 as? Searchable })
        favorites.1 = FavoritesStorage.shared.favorites.compactMap({ $0 as? Searchable })
//        today.1 = Array(searchable[87...90]).map({ TodayCellModel(searchable: $0, title: "Высшая математика", timeStart: Date().advanced(by: -300), timeEnd: Date().advanced(by: 500)) })
        
        if recent.1.isEmpty || favorites.1.isEmpty {
            recomendation.1 = ["главный", "бульвар"].compactMap({ title in
                searchable.filter({ $0.mainTitle?.lowercased().contains(title) ?? false }).first
            })
        }
        reload()
    }
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        
        FavoritesStorage.shared.onAdd.addHandler(handler: { [weak self] annotation in
            guard let self = self else { return }
            if let searchable = annotation as? Searchable {
                self.favorites.1.append(searchable)
            }
            self.reload()
        })
        
        FavoritesStorage.shared.onRemove.addHandler(handler: { [weak self] annotation in
            guard let self = self else { return }
            self.favorites.1 = self.favorites.1.filter({ $0 as? BaseAnnotation != annotation })
            self.reload()
        })
        
        SearchHistoryStorage.shared.onHistoryChange.addHandler(handler: { [weak self] annotation in
            guard let self = self else { return }
            self.recent.1 = annotation.compactMap({ $0 as? Searchable })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.reload()
            })
        })
    }
    
    func searchable(for indexPath: IndexPath) -> Searchable? {
        let data = compute[indexPath.section].1[indexPath.row]
        if let searchable = data as? Searchable {
            return searchable
        }
        
        if let today = data as? TodayCellModel {
            return today.searchable
        }
        
        return nil
    }
    
    func recalculate() {
        var sections = [today as (SectionType, [Any]), recent, favorites].filter({ !$0.1.isEmpty })
        
        if sections.count < 2 {
            sections.append(recomendation)
        }
        compute = sections
    }
    
    func reload() {
        recalculate()
        tableView?.reloadData()
    }
}

extension MainSearchData: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return compute.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = compute[section]
        return section.1.count
    }
    
    func titleForHeaderInSection(section: Int) -> String? {
        return compute[section].0.sectionName
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = compute[indexPath.section]
        
        if section.0 == .today {
            if let today = section.1[indexPath.row] as? TodayCellModel {
                let cell: UITableViewCell
                
                if today.searchable is OccupantAnnotation {
                    cell = tableView.dequeueReusableCell(withIdentifier: TodayCellOccupant.identifier)!
                } else {
                    cell = tableView.dequeueReusableCell(withIdentifier: TodayCellAttraction.identifier)!
                }
                
                (cell as? TodayCell)?.configurate(today)
                
                return cell
            }
        }
        
        if let searchable = searchable(for: indexPath) {
            return SearchShared.cell(tableView, for: searchable, indexPath: indexPath, grouped: true)
        }
        
        return UITableViewCell()
    
    }
}

//
//  SearchTableView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 26.03.2022.
//

import UIKit

protocol SearchTableViewDelegate {
    func searchTableWillBeginDragging(_ scrollView: UIScrollView);
    func searchTableDidScroll(_ scrollView: UIScrollView);
    func searchTableWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    func searchTable(didSelect searchable: Searchable)
}

class SearchTableView: UITableView {
    
    var searchTableViewDelegate: SearchTableViewDelegate?
    
    var searchable: [Searchable] = [] {
        didSet {
            proccesSearcheble(searchText: lastSearch, force: true)
        }
    }
    private var lastSearch: String = " "
    private var searchableSections: [(String,[Searchable])] = []
    
    lazy var emptyResult: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .callout)
        $0.textColor = .secondaryLabel
        $0.text = L10n.MapInfo.Search.emptySearchResult
        $0.isHidden = true
        return $0
    }(UILabel())
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        translatesAutoresizingMaskIntoConstraints = false
        SearchShared.registerCells(tableView: self)
        delegate = self
        dataSource = self
        backgroundColor = .clear
        separatorColor = .clear
        estimatedSectionHeaderHeight = 28
        
        addSubview(emptyResult)
        NSLayoutConstraint.activate([
            emptyResult.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            emptyResult.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        proccesSearcheble()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func searchable(for indexPath: IndexPath) -> Searchable {
        return searchableSections[indexPath.section].1[indexPath.row]
    }
    
    func proccesSearcheble(searchText: String = "", force: Bool = false) {
        let searchText = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if searchText == lastSearch && !force { return }
        lastSearch = searchText
        
        let searchable: [Searchable]
        
        if searchText.isEmpty {
            searchable = self.searchable
        } else {
            searchable = self.searchable.filter({ searchable in
                
                guard let title = searchable.mainTitle else { return false }
                
                return title.lowercased().contains(searchText)
            })
        }
        
        searchableSections = []
        
        let buildings = searchable.filter({ $0 is AttractionAnnotation }).sorted(by: { comparator($0, $1, searchText: searchText) })
        if !buildings.isEmpty {
            searchableSections.append((L10n.MapInfo.Search.buildings, buildings))
        }
        
        let occupants = searchable.filter({ $0 is OccupantAnnotation })
        
        let grouped = Dictionary(grouping: occupants, by: { $0.place })
        for group in grouped {
            searchableSections.append((group.key ?? "-", group.value.sorted(by: { comparator($0, $1, searchText: searchText) })))
        }
        
        reloadData()
        emptyResult.isHidden = !searchableSections.isEmpty
    }
}

extension SearchTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchableSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchableSections[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return SearchShared.cell(tableView, for: searchable(for: indexPath), indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SearchShared.header(tableView, for: section, title: searchableSections[section].0)
    }
}

extension SearchTableView: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchTableViewDelegate?.searchTableWillBeginDragging(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchTableViewDelegate?.searchTableDidScroll(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        searchTableViewDelegate?.searchTableWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        searchTableViewDelegate?.searchTable(didSelect: searchable(for: indexPath))
    }
}

fileprivate func comparator(_ lhs: Searchable, _ rhs: Searchable, searchText: String) -> Bool {
    guard let lhsTitle = lhs.mainTitle else { return false }
    guard let rhsTitle = rhs.mainTitle else { return true }
    
    guard let lhsIndex = lhsTitle.index(of: searchText),
          let rhsIndex = rhsTitle.index(of: searchText) else {
              return lhsTitle < rhsTitle
          }
    
    return (lhsIndex, lhsTitle) < (rhsIndex, rhsTitle)
}

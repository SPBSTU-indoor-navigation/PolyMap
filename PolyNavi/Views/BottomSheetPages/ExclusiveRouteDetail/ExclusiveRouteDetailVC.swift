//
//  ExclusiveRouteDetailVC.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 24.04.2022.
//

import UIKit
import MapKit

class ExclusiveRouteDetailVC: TableBottomSheetPage {
    var mapViewDelegate: MapViewDelegate
    var routeDetailInfo: ExclusiveRouteDetailInfo? {
        didSet {
            tableView.reloadData()
        }
    }
    var pathID: UUID?
    var from, to: MKAnnotation?
    
    init(closable: Bool = false, mapViewDelegate: MapViewDelegate) {
        self.mapViewDelegate = mapViewDelegate
        super.init(closable: closable, style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.text = L10n.MapInfo.Route.Info.title
        $0.font = .systemFont(ofSize: 29, weight: .bold)
        return $0
    }(UILabel())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.register(DetailCell.self, forCellReuseIdentifier: DetailCell.identifire)
        tableView.register(ExclusiveSearchableCell.self, forCellReuseIdentifier: ExclusiveSearchableCell.identifire)
        tableView.register(ExclusiveCloseCell.self, forCellReuseIdentifier: ExclusiveCloseCell.identifire)
        tableView.register(SearchGroupedHeaderView.self, forHeaderFooterViewReuseIdentifier: SearchGroupedHeaderView.identifier)
        tableView.estimatedSectionFooterHeight = 0
        
        
        navbar.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: tableView.wrapperView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: tableView.wrapperView.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: navbar.centerYAnchor),
        ])
        
    }
    
    override func beforeClose() {
        super.beforeClose()
        
        RouteDetailVC.toPoint = nil
        RouteDetailVC.fromPoint = nil
        
        DispatchQueue.main.async { [self] in
            [to, from].compactMap({ $0 }).forEach({
                mapViewDelegate.unpinAnnotation($0, animated: true)
            })
            
            if let pathID = pathID {
                mapViewDelegate.removePath(id: pathID)
            }
        }
    }

}

extension ExclusiveRouteDetailVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return routeDetailInfo?.sections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeDetailInfo?.sections[section].cellCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let routeDetailInfo = routeDetailInfo,
           let section = routeDetailInfo.section(for: indexPath.section),
           let cellFor = section as? CellFor {
            return cellFor.cellFor(tableView, indexPath)
        }
        
        return UITableViewCell()
    }
}

extension ExclusiveRouteDetailVC {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = routeDetailInfo?.section(for: section)?.title else { return nil }
        
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchGroupedHeaderView.identifier) as? SearchGroupedHeaderView else { return nil}
        
        header.configurate(text: title)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let routeDetailInfo = routeDetailInfo,
           let section = routeDetailInfo.section(for: indexPath.section)
        {
            (section as? SelectRowFor)?.didSelect(tableView, indexPath)
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return UITableView.automaticDimension
    }
}

extension ExclusiveRouteDetailVC {
    func show(from: MKAnnotation, to: MKAnnotation) {
        
        [self.to, self.from].compactMap({ $0 }).forEach({
            mapViewDelegate.unpinAnnotation($0, animated: true)
        })
        
        self.from = from
        self.to = to
        
        if let pathID = pathID {
            mapViewDelegate.removePath(id: pathID)
        }
    
        
        [to, from].forEach({
            mapViewDelegate.pinAnnotation($0, animated: true)
        })
        
        let result = PathFinder.shared.findPath(from: from, to: to)
        
        if let result = result {
            pathID = mapViewDelegate.addPath(path: result.path)
        } else {
            pathID = nil
        }
        
        if let result = result {
            routeDetailInfo = ExclusiveRouteDetailInfo(result: result, onExclusiveClose: {
                
                let alert = UIAlertController(title: "Sign out?", message: "You can always access your content by signing back in",         preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
                
                alert.addAction(UIAlertAction(title: "Завершить", style: .destructive, handler: { _ in
                    self.close(nil)
                }))
                
                alert.view.tintColor = Asset.accentColor.color
                self.present(alert, animated: true, completion: nil)
                
            })
        }
    }
}

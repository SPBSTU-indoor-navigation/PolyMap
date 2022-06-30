//
//  UnitDetailVC.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.02.2022.
//

import UIKit

fileprivate class TitleLabel: UILabel {
    var onHeightChange: ((CGFloat) -> ())?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        onHeightChange?(frame.height)
    }
}

class UnitDetailVC: NavbarBottomSheetPage {
    let titleTopOffset = 14.0
    var unitDetailInfo: UnitDetailInfo?
    var mapViewDelegate: MapViewDelegate?
    
    private var useTitleTransition = false
    
    private var titleHeight = 0.0 {
        willSet {
            if titleHeight != newValue {
                useTitleTransition = newValue > 40
                tableView.reloadData()
            }
        }
    }
    
    private lazy var titleLabel: TitleLabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 29, weight: .bold)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.onHeightChange = { [weak self] in self?.titleHeight = $0 }
        return $0
    }(TitleLabel())
    
    private lazy var titleNavbarLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alpha = 0
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        return $0
    }(UILabel())
    
    lazy var tableView: UITableView = {
        $0.register(SpaceCell.self, forCellReuseIdentifier: SpaceCell.identifire)
        $0.register(RouteInfoCell.self, forCellReuseIdentifier: RouteInfoCell.identifire)
        $0.register(DetailCell.self, forCellReuseIdentifier: DetailCell.identifire)
        $0.register(ShareAppClip.self, forCellReuseIdentifier: ShareAppClip.identifire)
        $0.register(SimpleShareCell.self, forCellReuseIdentifier: SimpleShareCell.identifire)
        $0.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.identifire)
        $0.register(TitleHeader.self, forHeaderFooterViewReuseIdentifier: TitleHeader.identifier)
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.sectionFooterHeight = 0
        
        return $0
    }(UITableView(frame: .zero, style: .insetGrouped))
    
    
    override func viewDidLoad() {
        background.addSubview(titleLabel)
        super.viewDidLoad()
        
        contentView.addSubview(tableView)
        
        navbarHeight = 60
        navbar.clipsToBounds = true
        navbar.addSubview(titleNavbarLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: background.topAnchor, constant: titleTopOffset),
            titleLabel.leadingAnchor.constraint(equalTo: tableView.wrapperView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -5),
            
            tableView.topAnchor.constraint(equalTo: navbar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            
            titleNavbarLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            titleNavbarLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            titleNavbarLabel.centerYAnchor.constraint(equalTo: navbar.centerYAnchor),
            
            closeButton.trailingAnchor.constraint(equalTo: tableView.wrapperView.trailingAnchor).with(priority: .defaultHigh)
        ])
    }
    
    
    override func onStateChange(horizontalSize: BottomSheetViewController.HorizontalSize) {
        super.onStateChange(horizontalSize: horizontalSize)
    }
    
    init(mapViewDelegate: MapViewDelegate?) {
        super.init(closable: true)
        self.mapViewDelegate = mapViewDelegate
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configurate(unitDetailInfo: UnitDetailInfo, showRouteButton: Bool = true) {
        if !showRouteButton {
            unitDetailInfo.sections = unitDetailInfo.sections.filter({ !($0 is UnitDetailInfo.Route) })
        }
        
        self.unitDetailInfo = unitDetailInfo
        titleLabel.text = unitDetailInfo.title
        titleNavbarLabel.text = unitDetailInfo.title
        
        tableView.reloadData()
    }
    
    func buildingPlanOpen(attraction: AttractionAnnotation) {
        delegate?.change(verticalSize: .small, animated: true)
        mapViewDelegate?.focus(on: attraction)
    }
}

extension UnitDetailVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let unitDetailInfo = unitDetailInfo else { return 0 }
        
        return unitDetailInfo.sections.count + useTitleTransition.intValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let unitDetailInfo = unitDetailInfo else { return 0 }
        
        if useTitleTransition && section == 0 { return 1 }
        
        return unitDetailInfo.sections[section - useTitleTransition.intValue].cellCount
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let unitDetailInfo = unitDetailInfo,
              let section = unitDetailInfo.section(for: section, title: useTitleTransition),
              let title = section.title else { return nil }
        
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleHeader.identifier) as! TitleHeader
        cell.configurate(text: title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if useTitleTransition && indexPath.row == 0 && indexPath.section == 0 {
            var cell: UITableViewCell?
            UIView.performWithoutAnimation {
                let spacer = tableView.dequeueReusableCell(withIdentifier: SpaceCell.identifire, for: indexPath) as! SpaceCell
                spacer.configurate(height: titleLabel.frame.height - navbar.frame.height + titleTopOffset + 3)
                cell = spacer
            }
            
            cell!.selectionStyle = .none
            return cell!
        }
        
        if let unitDetailInfo = unitDetailInfo,
           let section = unitDetailInfo.section(for: indexPath.section, title: useTitleTransition),
           let cellFor = section as? CellFor {
            return cellFor.cellFor(tableView, indexPath)
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0,
           let unitDetailInfo = unitDetailInfo,
           let section = unitDetailInfo.section(for: section, title: useTitleTransition),
           let _ = section.title {
            return UITableView.automaticDimension
        }
        
        
        if section == 0 {
            return 0
        }
        
        return UITableView.automaticDimension
    }

}

extension Bool {
    var intValue: Int {
        return self ? 1 : 0
    }
}

extension UnitDetailVC: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging(scrollView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let unitDetailInfo = unitDetailInfo,
           let section = unitDetailInfo.section(for: indexPath.section, title: useTitleTransition)
        {
            (section as? SelectRowFor)?.didSelect(tableView, indexPath)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
        titleLabel.transform = CGAffineTransform(translationX: 0, y: -scrollView.topContentOffset.y)
        
        if useTitleTransition {
            titleLabel.transform = CGAffineTransform(translationX: 0, y: -scrollView.topContentOffset.y)
            let offset = titleLabel.frame.height - navbar.frame.height + titleTopOffset + 3
            let a = max(0, min(1, (scrollView.topContentOffset.y - offset) / 30))

            titleLabel.alpha = 1 - a
            titleNavbarLabel.alpha = max(0, min(1, (scrollView.topContentOffset.y - offset - 20) / 30))
            update(progress: a)
        } else {
            titleLabel.transform = CGAffineTransform(translationX: 0, y: (max(0, -scrollView.topContentOffset.y)))
            update(progress: scrollView.topContentOffset.y)
        }
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
}

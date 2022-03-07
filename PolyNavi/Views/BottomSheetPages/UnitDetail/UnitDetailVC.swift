//
//  UnitDetailVC.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.02.2022.
//

import UIKit

protocol CellFor {
    func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell
}

class OccupantInfo {
    var title: String = ""
    var sections: [Section] = []
    

    class Section {
        var title: String? { return nil }
        var cellCount: Int { return 1 }
    }
    
    class Route: Section, CellFor {
        var showRoute = true
        var showIndoor = true
        
        init(showRoute: Bool = true, showIndoor: Bool = true) {
            self.showRoute = showRoute
            self.showIndoor = showIndoor
        }
        
        func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: RouteInfoCell.identifire, for: indexPath) as! RouteInfoCell
            cell.selectionStyle = .none
            return cell
        }
    }
    
    class Detail: Section, CellFor  {
        var content: [(String, String)] = []
        
        override var title: String? { return "Detail" }
        override var cellCount: Int {
            return content.count
        }
        
        init(phone: String? = nil, email: String? = nil, website: String? = nil, address: String? = nil) {
            if let phone = phone { content.append((L10n.MapInfo.Detail.phone, phone)) }
            if let email = email { content.append((L10n.MapInfo.Detail.email, email)) }
            if let website = website { content.append((L10n.MapInfo.Detail.website, website)) }
            if let address = address { content.append((L10n.MapInfo.Detail.address, address)) }
        }
        
        func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier) as! DetailCell
            
            cell.configurate(title: content[indexPath.row].0, content: content[indexPath.row].1)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    class Report: Section, CellFor {
        override var cellCount: Int { return 2 }
        
        func cellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
            
            let image = UIImage(systemName: indexPath.row == 0 ? "star.fill" : "exclamationmark.bubble.fill")
            let text = indexPath.row == 0 ? "Favorites" : "Report an Issue"
            
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
    
    func section(for row: Int, title: Bool) -> Section? {
        return sections[row - title.intValue]
    }
    
}

class UnitDetailVC: NavbarBottomSheetPage {
    let titleTopOffset = 14.0
    var occupantInfo: OccupantInfo?
    
    private var useTitleTransition = false
    
    private var titleHeight = 0.0 {
        willSet {
            if titleHeight != newValue {
                useTitleTransition = newValue > 40
                tableView.reloadData()
            }
        }
    }
    
    private lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 29, weight: .bold)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        return $0
    }(UILabel())
    
    private lazy var titleNavbarLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alpha = 0
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        return $0
    }(UILabel())
    
    lazy var tableView: UITableView = {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        $0.register(Spacer.self, forCellReuseIdentifier: "spacer")
        $0.register(RouteInfoCell.self, forCellReuseIdentifier: RouteInfoCell.identifire)
        $0.register(DetailCell.self, forCellReuseIdentifier: DetailCell.identifier)
        $0.register(TitleHeader.self, forHeaderFooterViewReuseIdentifier: TitleHeader.identifier)
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.sectionFooterHeight = 0
        return $0
    }(UITableView(frame: .zero, style: .insetGrouped))
    
    
    override func viewDidLoad() {
        background.addSubview(tableView)
        background.addSubview(titleLabel)
        super.viewDidLoad()
        
        navbarHeight = 60
        navbar.clipsToBounds = true
        navbar.addSubview(titleNavbarLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: background.topAnchor, constant: titleTopOffset),
            titleLabel.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -45),
            
            tableView.topAnchor.constraint(equalTo: navbar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            
            titleNavbarLabel.leadingAnchor.constraint(equalTo: navbar.leadingAnchor, constant: 16),
            titleNavbarLabel.trailingAnchor.constraint(equalTo: navbar.trailingAnchor, constant: -45 ),
            titleNavbarLabel.centerYAnchor.constraint(equalTo: navbar.centerYAnchor)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleHeight = titleLabel.frame.height
    }
    
    override func onStateChange(horizontalSize: BottomSheetViewController.HorizontalSize) {
        super.onStateChange(horizontalSize: horizontalSize)
    }
    
    func configurate(occupantInfo: OccupantInfo) {
        self.occupantInfo = occupantInfo
        titleLabel.text = occupantInfo.title
        titleNavbarLabel.text = occupantInfo.title
        
        titleLabel.sizeToFit()
        titleHeight = titleLabel.frame.height
        tableView.reloadData()
    }
}

extension UnitDetailVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let occupantInfo = occupantInfo else { return 0 }
        
        return occupantInfo.sections.count + useTitleTransition.intValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let occupantInfo = occupantInfo else { return 0 }
        
        if useTitleTransition && section == 0 { return 1 }
        
        return occupantInfo.sections[section - useTitleTransition.intValue].cellCount
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let occupantInfo = occupantInfo,
              let section = occupantInfo.section(for: section, title: useTitleTransition),
              let title = section.title else { return nil }
        
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleHeader.identifier) as! TitleHeader
        cell.configurate(text: title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if useTitleTransition && indexPath.row == 0 && indexPath.section == 0 {
            var cell: UITableViewCell?
            UIView.performWithoutAnimation {
                let spacer = tableView.dequeueReusableCell(withIdentifier: "spacer", for: indexPath) as! Spacer
                spacer.configurate(height: titleLabel.frame.height - navbar.frame.height + titleTopOffset + 3)
                cell = spacer
            }
            
            cell!.selectionStyle = .none
            return cell!
        }
        
        if let occupantInfo = occupantInfo,
           let section = occupantInfo.section(for: indexPath.section, title: useTitleTransition),
           let cellFor = section as? CellFor {
            return cellFor.cellFor(tableView, indexPath)
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if useTitleTransition && indexPath.row == 0 && indexPath.section == 0 { return nil }
        return indexPath
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
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
        titleLabel.transform = CGAffineTransform(translationX: 0, y: -scrollView.topContentOffset.y)
        
        if useTitleTransition {
            titleLabel.transform = CGAffineTransform(translationX: 0, y: -scrollView.topContentOffset.y)
            let offset = titleLabel.frame.height - navbar.frame.height + titleTopOffset + 3
            let a = max(0, min(1, (scrollView.topContentOffset.y - offset) / 30))

    //        if (1 - a < 0.5 && titleLabel.alpha == 1) {
    //            UIView.animate(withDuration: 0.3) { [self] in
    //                self.titleLabel.alpha = 0
    //                self.titleNavbarLabel.alpha = 1
    //            }
    //        } else if (1 - a > 0.5 && titleLabel.alpha != 1){
    //            UIView.animate(withDuration: 0.3) { [self] in
    //                self.titleLabel.alpha = 1
    //                self.titleNavbarLabel.alpha = 0
    //            }
    //        }
            
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

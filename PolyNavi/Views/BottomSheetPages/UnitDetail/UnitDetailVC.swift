//
//  UnitDetailVC.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.02.2022.
//

import UIKit

class UnitDetailVC: NavbarBottomSheetPage {
    let titleTopOffset = 14.0
    
    private var useTitleTransition = false {
        willSet {
            if useTitleTransition != newValue {
                tableView.reloadData()
            }
        }
    }
    
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
        $0.register(TitleHeader.self, forHeaderFooterViewReuseIdentifier: "titleHeader")
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.allowsSelection = false
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
        
        configurate(titleText: "Saint Petersburg Saint Petersburg Saint Petersburg")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleHeight = titleLabel.frame.height
    }
    
    override func onStateChange(horizontalSize: BottomSheetViewController.HorizontalSize) {
        super.onStateChange(horizontalSize: horizontalSize)
        configurate(titleText: titleLabel.text!)
    }
    
    func configurate(titleText: String) {
        titleLabel.text = titleText
        titleNavbarLabel.text = titleText
        tableView.reloadData()
    }
    
}

extension UnitDetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 || (section == 0 && useTitleTransition) { return 1 }
        return 5
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 3 {
            var cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "titleHeader")
            return cell
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        UIView.animate(withDuration: 0.001) {
            view.layoutIfNeeded()
            view.layoutSubviews()
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 && indexPath.section == 0 && useTitleTransition {
            
            var cell: UITableViewCell?
            UIView.performWithoutAnimation {
                let spacer = tableView.dequeueReusableCell(withIdentifier: "spacer", for: indexPath) as! Spacer
                spacer.configurate(height: titleLabel.frame.height - navbar.frame.height + titleTopOffset + 3)
                cell = spacer
            }
            
            return cell!
            
        }
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: RouteInfoCell.identifire, for: indexPath) as! RouteInfoCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)

        cell.backgroundColor = Asset.Colors.bottomSheetGroupped.color
        cell.textLabel?.text = "Unit \(indexPath.row)"
        return cell
    }
    
    func setupColor(color: UIColor) {
        view.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && useTitleTransition {
            return 0
        }
        
        return UITableView.automaticDimension
    }

}

extension UnitDetailVC: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging(scrollView)
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


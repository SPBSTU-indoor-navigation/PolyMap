//
//  TimetableViewController.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 10.10.2021.
//

import UIKit
import SkeletonView

class TimetableViewController: UIViewController {
    
    //MARK:-Properties
    
    internal var arrayOfDaysWithLessons: [TimetableWeek.TimetableDay] = []

    internal lazy var tableView: UITableView = {
        $0.register(LessonCellView.self, forCellReuseIdentifier: LessonCellView.identifire)
        $0.register(DateTableViewCell.self, forCellReuseIdentifier: DateTableViewCell.identifire)
        $0.register(EmptyLessonTableViewCell.self, forCellReuseIdentifier: EmptyLessonTableViewCell.identifire)
        $0.register(SkeletonDateTableViewCell.self, forCellReuseIdentifier: SkeletonDateTableViewCell.identifire)
        $0.register(SkeletonLessonCellView.self, forCellReuseIdentifier: SkeletonLessonCellView.identifire)
        $0.separatorStyle = .none
        $0.allowsSelection = false
        $0.backgroundColor = .clear
        $0.dataSource = self
        $0.delegate = self
        $0.isSkeletonable = true
        $0.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 60))
        $0.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 60))
        $0.showsVerticalScrollIndicator = false
        return $0
    }(UITableView())
    
    internal lazy var headerView: UIView = {
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        $0.backgroundColor = .secondarySystemGroupedBackground
        return $0
    }(UIView())
    
    internal lazy var saveAreaLayer: UIView = {
        $0.backgroundColor = .secondarySystemGroupedBackground
        return $0
    }(UIView())
    
    internal lazy var titleLabel: UILabel = {
        $0.text = "Расписание"
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        return $0
    }(UILabel())
    
    
    //MARK:- Life cicle 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        layoutViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
}


//MARK:- LayoutView
private extension TimetableViewController {
    func layoutViews() {
        [tableView, headerView, titleLabel, saveAreaLayer].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        headerView.addSubview(titleLabel)
        [saveAreaLayer, tableView, headerView].forEach { self.view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            saveAreaLayer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            saveAreaLayer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            saveAreaLayer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            saveAreaLayer.heightAnchor.constraint(equalToConstant: 100),
            
            headerView.topAnchor.constraint(equalTo: saveAreaLayer.bottomAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),
            
            tableView.topAnchor.constraint(equalTo: headerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}


//MARK:- Api
private extension TimetableViewController {
    func loadData() {
        
        UIView.transition(with: tableView, duration: 0.3, options: .curveLinear, animations: { [weak self] in
            let gradient = SkeletonGradient(baseColor: UIColor.white, secondaryColor: .gray)
            self?.tableView.showAnimatedGradientSkeleton(usingGradient: gradient, animation: nil, transition: .crossDissolve(0.25))
        }, completion: nil)
        
        TimetableProvider.shared.loadTimetable(startDate: nil) { response in
            guard let response = response else { return }
            let timetable = TimetableWeek.convert(response)
            self.arrayOfDaysWithLessons = timetable.days.map { pair in
                return TimetableWeek.TimetableDay(date: pair.date, lessons: LessonModel.createCorrectTimeTable(currentArray: pair.lessons))
            }
            DispatchQueue.main.async { [weak self] in
                self?.tableView.stopSkeletonAnimation()
                self?.view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                self?.tableView.reloadData()
            }
        }
    }
}

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
        $0.register(EmptyLessonTableViewCell.self, forCellReuseIdentifier: EmptyLessonTableViewCell.identifire)
        $0.register(SkeletonDateTableViewCell.self, forCellReuseIdentifier: SkeletonDateTableViewCell.identifire)
        $0.register(SkeletonLessonCellView.self, forCellReuseIdentifier: SkeletonLessonCellView.identifire)
        $0.separatorStyle = .none
        $0.allowsSelection = false
        $0.backgroundColor = .clear
        $0.dataSource = self
        $0.delegate = self
        $0.isSkeletonable = true
        $0.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 5))
        $0.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        $0.showsVerticalScrollIndicator = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UITableView(frame: .zero, style: .insetGrouped))
    
    //MARK:- Life cicle 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        layoutViews()
        loadData()
        
        self.navigationItem.title = L10n.Timetable.title
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonAction(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonAction(_:)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}


//MARK:- LayoutView
private extension TimetableViewController {
    func layoutViews() {
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
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
        
        TimetableProvider.shared.loadTimetable(
            group: Group(id: 33843, kind: 0, level: 0, name: "", spec: "", type: "", year: 0)) { response in
                guard let response = response.data else { return }
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


//MARK: - Selector Bar item functions

private extension TimetableViewController {
    
    @objc
    func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func editButtonAction(_ sender: UIButton) {
        //TODO:- create editing of timetable: change group or teacher.
    }
    
}

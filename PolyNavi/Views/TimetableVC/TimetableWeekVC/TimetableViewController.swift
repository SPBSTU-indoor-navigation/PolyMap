//
//  TimetableViewController.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 10.10.2021.
//

import UIKit
import SkeletonView

class TimetableViewController: UIViewController {
    
    var date = Date()
    
    init(date: Date) {
        super.init(nibName: nil, bundle: nil)
        self.date = date
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:-Properties
    
    internal var arrayOfDaysWithLessons: [TimetableWeek.TimetableDay] = []
    
    internal lazy var tableView: UITableView = {
        $0.register(LessonCellView.self, forCellReuseIdentifier: LessonCellView.identifire)
        $0.register(TimetableBreakTableViewCell.self, forCellReuseIdentifier: TimetableBreakTableViewCell.identifire)
        $0.register(DateTableViewCell.self, forHeaderFooterViewReuseIdentifier: DateTableViewCell.identifire)
        $0.allowsSelection = false
        $0.dataSource = self
        $0.delegate = self
        $0.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 5))
        $0.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        $0.showsVerticalScrollIndicator = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        return $0
    }(UITableView(frame: .zero, style: .insetGrouped))
    
    internal lazy var loader: UIActivityIndicatorView = {
        $0.style = .large
        $0.isHidden = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIActivityIndicatorView())
    
    //MARK:- Life cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        layoutViews()
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}


//MARK:- LayoutView
private extension TimetableViewController {
    func layoutViews() {
        view.addSubview(loader)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}


//MARK:- Api
extension TimetableViewController {
    public func loadData() {
        self.arrayOfDaysWithLessons = []
        self.tableView.reloadData()
        
        loader.startAnimating()
        
        let id = (GroupsAndTeacherStorage.shared.currentFilter == .groups) ? GroupsAndTeacherStorage.shared.currentGroupNumber?.ID : GroupsAndTeacherStorage.shared.currentTeachersName?.ID
        
        TimetableProvider.shared.loadTimetabe(id: id ?? -1, filter: GroupsAndTeacherStorage.shared.currentFilter, startDate: date, fromCache: true) {
            response in
            guard let response = response.data else { return }
            let timetable = TimetableWeek.convert(response)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) { [weak self] in
                self?.arrayOfDaysWithLessons = timetable.days.map { pair in
                    return TimetableWeek.TimetableDay(date: pair.date, timetableCell: LessonModel.createCorrectTimeTable(currentArray: pair.timetableCell))
                }
                self?.tableView.reloadData()
                self?.loader.stopAnimating()
            }
        }
    }
}

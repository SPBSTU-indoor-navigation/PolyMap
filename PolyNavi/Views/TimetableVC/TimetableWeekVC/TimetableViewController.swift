//
//  TimetableViewController.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 10.10.2021.
//

import UIKit
import SkeletonView

class TimetableViewController: UIViewController {
    
    //Properties
    var date = Date()
    var appeared = false
    var checkCurrentDateAfterLoading: Bool = false
    var thisWeekDontHaveCurrentDay: Bool = false
    
    internal var arrayOfDaysWithLessons: [TimetableWeek.TimetableDay] = []
    internal var weekData: Timetable.Week?
    
    //Blocks
    var willAppear: ((TimetableViewController) -> Void)?
    var updateContentOffsetBlock: ((TimetableViewController, CGFloat) -> Void)?
    var updateButtonTitle: ((Bool, Bool) -> Void)?
    var updateNavBarDate: ((Date, Timetable.Week?) -> Void)?
    
    //MARK:-Views
    internal lazy var refreshControl: UIRefreshControl = {
        $0.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        return $0
    }(UIRefreshControl())
    
    internal lazy var tableView: UITableView = {
        $0.register(LessonCellView.self, forCellReuseIdentifier: LessonCellView.identifire)
        $0.register(TimetableBreakTableViewCell.self, forCellReuseIdentifier: TimetableBreakTableViewCell.identifire)
        $0.register(DateTableViewCell.self, forHeaderFooterViewReuseIdentifier: DateTableViewCell.identifire)
        $0.allowsSelection = false
        $0.dataSource = self
        $0.delegate = self
        $0.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
        $0.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 5))
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
    
    internal lazy var emptyWeekView: TimetableEmptyView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
        $0.refreshButton.addTarget(self, action: #selector(refreshPage(_:)), for: .touchUpInside)
        $0.becomeFirstResponder()
        return $0
    }(TimetableEmptyView(frame: .zero))
    
    
    init(date: Date) {
        super.init(nibName: nil, bundle: nil)
        self.date = date
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK:- Initialize and Live cycle
extension TimetableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        layoutViews()
        if Calendar.current.isDate(date, inSameDayAs: Date()) {
            self.checkCurrentDateAfterLoading = true
        }
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Calendar.current.isDate(date, inSameDayAs: Date()) {
            self.checkCurrentDateAfterLoading = true
        }
        willAppear?(self)
        updateNavBarDate?(date, weekData)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateContentOffsetBlock?(self, tableView.contentOffset.y)
        let currentDate = Calendar.current.isDate(date, inSameDayAs: Date())
        updateButtonTitle?(currentDate, thisWeekDontHaveCurrentDay)
        appeared = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appeared = false
    }
    
}


//MARK:- Button and refresh handlers
extension TimetableViewController {
    
    @objc
    func handleRefreshControl() {
        refreshDate() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc
    func refreshPage(_ sender: UIButton?) {
        emptyWeekView.isHidden = true
        loader.startAnimating()
        refreshDate() { [weak self] in
            self?.loader.stopAnimating()
        }
    }
}

//MARK:- Scroll to current Date in table view
extension TimetableViewController {
    
    public func scrollToCurrentDate(date: Date) {
        guard let currentIndex = arrayOfDaysWithLessons.firstIndex(where: { Calendar.current.isDate($0.date!, inSameDayAs: date) })  else {
            return
        }
        
        let indexPath = IndexPath(row: 0, section: currentIndex)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
}


//MARK:- LayoutView
private extension TimetableViewController {
    func layoutViews() {
        view.addSubview(loader)
        view.addSubview(tableView)
        view.addSubview(emptyWeekView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emptyWeekView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyWeekView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyWeekView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyWeekView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}


//MARK:- Api
internal extension TimetableViewController {
    func loadData() {
        arrayOfDaysWithLessons = []
        tableView.reloadData()
        emptyWeekView.isHidden = true
        tableView.refreshControl = nil
        
        loader.startAnimating()
        
        let id = (GroupsAndTeacherStorage.shared.currentFilter == .groups) ? GroupsAndTeacherStorage.shared.currentGroupNumber?.ID : GroupsAndTeacherStorage.shared.currentTeachersName?.ID
        
        TimetableProvider.shared.loadTimetabe(id: id ?? -1, filter: GroupsAndTeacherStorage.shared.currentFilter, startDate: date, fromCache: true) {
            [weak self] response in
            guard let self = self, let response = response.data else { return }
            self.arrayOfDaysWithLessons = TimetableWeek.convert(response).days.map { pair in
                return TimetableWeek.TimetableDay(date: pair.date, timetableCell: LessonModel.createCorrectTimeTable(currentArray: pair.timetableCell))
            }
            self.weekData = response.week
            
            DispatchQueue.main.async() { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
                self.loader.stopAnimating()
                self.tableView.refreshControl = self.refreshControl
                self.emptyWeekView.isHidden = !self.arrayOfDaysWithLessons.isEmpty
                self.tableView.isHidden = self.arrayOfDaysWithLessons.isEmpty
                if self.appeared {
                    self.updateNavBarDate?(self.date, self.weekData)
                }
                if self.checkCurrentDateAfterLoading {
                    let indexCurrent = self.arrayOfDaysWithLessons.firstIndex(where: {Calendar.current.isDate($0.date!, inSameDayAs: Date())})
                    self.thisWeekDontHaveCurrentDay = indexCurrent == nil
                    self.updateButtonTitle?(true, self.thisWeekDontHaveCurrentDay)
                }
            }
        }
    }
    
    func refreshDate(completion: @escaping () -> Void = {}) {
        let id = (GroupsAndTeacherStorage.shared.currentFilter == .groups) ? GroupsAndTeacherStorage.shared.currentGroupNumber?.ID : GroupsAndTeacherStorage.shared.currentTeachersName?.ID
        TimetableProvider.shared.loadTimetabe(id: id ?? -1, filter: GroupsAndTeacherStorage.shared.currentFilter, startDate: date, fromCache: false) {
            [weak self] response in
    
            guard let self = self, let response = response.data else { return }
            self.arrayOfDaysWithLessons = TimetableWeek.convert(response).days.map { pair in
                return TimetableWeek.TimetableDay(date: pair.date, timetableCell: LessonModel.createCorrectTimeTable(currentArray: pair.timetableCell))
            }
            
            DispatchQueue.main.async() { [weak self] in
                guard let self = self else { return }
                self.emptyWeekView.isHidden = !self.arrayOfDaysWithLessons.isEmpty
                self.tableView.isHidden = self.arrayOfDaysWithLessons.isEmpty
                self.tableView.reloadData()
                completion()
            }
        }
    }
}

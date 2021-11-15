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
    var willAppear: ((TimetableViewController) -> Void)?
    var updateContentOffsetBlock: ((TimetableViewController, CGFloat) -> Void)?
    var appeared = false
    
    init(date: Date) {
        super.init(nibName: nil, bundle: nil)
        self.date = date
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        layoutViews()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        willAppear?(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateContentOffsetBlock?(self, tableView.contentOffset.y)
        appeared = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appeared = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if appeared {
            self.updateContentOffsetBlock?(self, scrollView.contentOffset.y)
        }
    }
    
    //MARK:-Properties
    
    internal var arrayOfDaysWithLessons: [TimetableWeek.TimetableDay] = []
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
    
    internal lazy var emptyWeek: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(systemName: "bed.double", withConfiguration: UIImage.SymbolConfiguration(pointSize: 100))
        $0.isHidden = true
        return $0
    }(UIImageView())
    
    internal lazy var emptyWeekDscription: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .preferredFont(forTextStyle: .callout)
        $0.text = L10n.Timetable.emptyWeek
        return $0
    }(UILabel())
    
    internal lazy var refreshButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("Refresh", for: .normal)
        $0.addTarget(self, action: #selector(refreshPage(_:)), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    

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
//      TODO: sender.IS_DISABLE = TURE
        refreshDate() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                TODO: sender.IS_DISABLE = FALSE
            }
        }
    }
    
}


//MARK:- LayoutView
private extension TimetableViewController {
    func layoutViews() {
        view.addSubview(loader)
        view.addSubview(tableView)
        view.addSubview(emptyWeek)
        
        emptyWeek.addSubview(emptyWeekDscription)
        emptyWeek.addSubview(refreshButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emptyWeek.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyWeek.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            refreshButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            refreshButton.centerXAnchor.constraint(equalTo: emptyWeek.centerXAnchor),
            
            emptyWeekDscription.centerXAnchor.constraint(equalTo: emptyWeek.centerXAnchor),
            emptyWeekDscription.topAnchor.constraint(equalTo: emptyWeek.bottomAnchor, constant: 10),
            emptyWeekDscription.widthAnchor.constraint(lessThanOrEqualToConstant: 400),
            emptyWeekDscription.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -20)
        ])
    }
}


//MARK:- Api
extension TimetableViewController {
    public func loadData() {
        arrayOfDaysWithLessons = []
        tableView.reloadData()
        emptyWeek.isHidden = true
        tableView.refreshControl = nil
        
        loader.startAnimating()
        
        let id = (GroupsAndTeacherStorage.shared.currentFilter == .groups) ? GroupsAndTeacherStorage.shared.currentGroupNumber?.ID : GroupsAndTeacherStorage.shared.currentTeachersName?.ID
        
        TimetableProvider.shared.loadTimetabe(id: id ?? -1, filter: GroupsAndTeacherStorage.shared.currentFilter, startDate: date, fromCache: true) {
            response in
            guard let response = response.data else { return }
            self.arrayOfDaysWithLessons = TimetableWeek.convert(response).days.map { pair in
                return TimetableWeek.TimetableDay(date: pair.date, timetableCell: LessonModel.createCorrectTimeTable(currentArray: pair.timetableCell))
            }
            
            DispatchQueue.main.async() { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
                self.loader.stopAnimating()
                self.tableView.refreshControl = self.refreshControl
                self.emptyWeek.isHidden = !self.arrayOfDaysWithLessons.isEmpty
                self.tableView.isHidden = self.arrayOfDaysWithLessons.isEmpty

            }
        }
    }
    
    public func refreshDate(completion: @escaping () -> Void = {}) {
        let id = (GroupsAndTeacherStorage.shared.currentFilter == .groups) ? GroupsAndTeacherStorage.shared.currentGroupNumber?.ID : GroupsAndTeacherStorage.shared.currentTeachersName?.ID
        TimetableProvider.shared.loadTimetabe(id: id ?? -1, filter: GroupsAndTeacherStorage.shared.currentFilter, startDate: date, fromCache: false) {
            response in

            guard let response = response.data else { return }
            self.arrayOfDaysWithLessons = TimetableWeek.convert(response).days.map { pair in
                return TimetableWeek.TimetableDay(date: pair.date, timetableCell: LessonModel.createCorrectTimeTable(currentArray: pair.timetableCell))
            }
            
            DispatchQueue.main.async() { [weak self] in
                guard let self = self else { return }
                self.emptyWeek.isHidden = !self.arrayOfDaysWithLessons.isEmpty
                self.tableView.isHidden = self.arrayOfDaysWithLessons.isEmpty
                self.tableView.reloadData()
                completion()
            }
        }
    }
}

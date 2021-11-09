//
//  TimetableViewController.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 10.10.2021.
//

import UIKit
import SkeletonView

class TimetableViewController: UIViewController {
    
    var loading = false
    
    init(date: Date) {
        super.init(nibName: nil, bundle: nil)
        print(date)
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
        $0.register(SkeletonDateTableViewCell.self, forCellReuseIdentifier: SkeletonDateTableViewCell.identifire)
        $0.register(SkeletonLessonCellView.self, forCellReuseIdentifier: SkeletonLessonCellView.identifire)
        $0.allowsSelection = false
        $0.dataSource = self
        $0.delegate = self
        $0.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 5))
        $0.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        $0.showsVerticalScrollIndicator = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UITableView(frame: .zero, style: .insetGrouped))
    
    //MARK:- Life cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = L10n.Timetable.title
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.Timetable.editButton, style: .plain, target: self, action: #selector(editButtonAction(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonAction(_:)))
        layoutViews()
        loadData()
        loading = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            if self.loading {
                
                self.tableView.isSkeletonable = true
                self.tableView.showSkeleton()
            }
        })
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
        
        //        UIView.transition(with: tableView, duration: 0.3, options: .curveLinear, animations: { [weak self] in
        //            let gradient = SkeletonGradient(baseColor: .clear, secondaryColor: .systemGray4)
        //            self?.tableView.showAnimatedGradientSkeleton(usingGradient: gradient, animation: nil, transition: .crossDissolve(0.25))
        //        }, completion: nil)
        //        self.tableView.showSkeleton()
        
        let id = (GroupsAndTeacherStorage.shared.currentFilter == .groups) ? GroupsAndTeacherStorage.shared.currentGroupNumber?.ID : GroupsAndTeacherStorage.shared.currentTeachersName?.ID
        
        TimetableProvider.shared.loadTimetabe(id: id ?? -1, filter: GroupsAndTeacherStorage.shared.currentFilter) {
            response in
            guard let response = response.data else { return }
            let timetable = TimetableWeek.convert(response)
            self.arrayOfDaysWithLessons = timetable.days.map { pair in
                return TimetableWeek.TimetableDay(date: pair.date, timetableCell: LessonModel.createCorrectTimeTable(currentArray: pair.timetableCell))
            }
            DispatchQueue.main.async { [weak self] in
                //                    self?.tableView.stopSkeletonAnimation()
                //                    self?.view.hideSkeleton(transition: .crossDissolve(0.25))
                //                    self?.view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                self?.tableView.reloadData()
                self?.tableView.hideSkeleton(transition: .crossDissolve(0.25))
                self?.loading = false
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
        let vc = SettingTimetableVC()
        vc.finishAction = { [weak self] in
            self?.loadData()
        }
        let navSettingVC = UINavigationController(rootViewController: vc)
        self.present(navSettingVC, animated: true)
    }
    
}
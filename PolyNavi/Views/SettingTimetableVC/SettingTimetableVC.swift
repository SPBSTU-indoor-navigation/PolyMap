//
//  SettingTimetableVC.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 17.10.2021.
//

import UIKit

class SettingTimetableVC: UIViewController {
    
    //MARK:- Values
    private let cellID = "GroupCell"
    private let itemsSegmentStrings: [String] = [L10n.Settings.titleOfGroupsView, L10n.Settings.titleOfTeachersView]
    private let titlesOfSection: [String] = [L10n.Settings.settingOfGroup, L10n.Settings.settingOfTeacher]
    private var cellTitles: [[String]] = [
        [L10n.Settings.titleOfInstituteCell, L10n.Settings.titleOfGroupCell],
        [L10n.Settings.titleOfTeacherCell]
    ]
    private var selectedIndex: Int = 0;
    
    //MARK:- Views
    private lazy var segmentControl: UISegmentedControl = {
        $0.selectedSegmentIndex = 0
        $0.addTarget(self, action: #selector(segmentChangeValueAction(_:)), for: .valueChanged)
        return $0
    }(UISegmentedControl(items: itemsSegmentStrings))
    
    private lazy var tableView: UITableView = {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        $0.delegate = self
        $0.dataSource = self 
        return $0
    }(UITableView(frame: .zero, style: .insetGrouped))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .secondarySystemBackground
        
        self.navigationItem.title = L10n.Settings.title
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonAction(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonAction(_:)))
        
        setViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
}


//MARK:- Layout subviews
private extension SettingTimetableVC {
    func setViews() {
        [segmentControl, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}


//MARK:- Segment change value action
private extension SettingTimetableVC {
    @objc
    func segmentChangeValueAction(_ sender: UISegmentedControl) {
        selectedIndex = sender.selectedSegmentIndex
        GroupsAndTeacherStorage.shared.fillter = selectedIndex == 0 ? .groups : .teachers
        tableView.reloadData()
    }
    
    @objc
    func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func doneButtonAction(_ sender: UIButton) {}
}


//MARK:- TableView delegate and datasource
extension SettingTimetableVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return selectedIndex == 0 ? L10n.Settings.settingOfGroup : L10n.Settings.settingOfTeacher
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (selectedIndex == 0) {
            if GroupsAndTeacherStorage.shared.institute == nil {
                return cellTitles[selectedIndex].count - 1
            }
        }
        return cellTitles[selectedIndex].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let textLabel = UILabel()
        textLabel.font = .preferredFont(forTextStyle: .headline)
        let title = cellTitles[selectedIndex][indexPath.row]
        cell.textLabel?.text = title + ": " + getStatus(indexRow: indexPath.row)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChoosingWithSearchTableView()
        if (selectedIndex == 0) {
            if (indexPath.row == 0) {
                vc.loadFunction = { completion in
                    TimetableProvider.shared.loadFaculties { response in
                        let data = response.data!
                        completion(data.convert())
                    }
                }
                vc.choosingFunction = { val in
                    GroupsAndTeacherStorage.shared.institute = val
                }
                vc.selectedID = GroupsAndTeacherStorage.shared.institute?.ID
                vc.navigationItem.title = L10n.Settings.titleOfInstituteCell
            } else {
                guard let institute = GroupsAndTeacherStorage.shared.institute else {return}
                vc.loadFunction = { completion in
                    TimetableProvider.shared.loadGroups(faculty: Faculty(id: institute.ID, name: institute.title, abbr: "")) { response in
                        let data = response.data!
                        completion(data.convert())
                    }
                }
                vc.choosingFunction = { val in
                    GroupsAndTeacherStorage.shared.groupNumber = val
                }
                vc.navigationItem.title = L10n.Settings.titleOfGroupCell
            }
        } else {
            vc.loadFunction = { completion in
                TimetableProvider.shared.loadTeachers { response in
                    let data = response.data!
                    completion(data.convert())
                }
            }
            vc.choosingFunction = { val in
                GroupsAndTeacherStorage.shared.teachersName = val
            }
            vc.navigationItem.title = L10n.Settings.titleOfTeacherCell
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func getStatus(indexRow: Int) -> String {
        var str: String = ""
        if (selectedIndex == 0) {
            str = (indexRow == 0) ? "\(GroupsAndTeacherStorage.shared.getInstituteStringWithStatus())" : "\(GroupsAndTeacherStorage.shared.getGroupStringWithStatus())"
        } else {
            str = GroupsAndTeacherStorage.shared.getTeacherStringWithStatus()
        }
        return str
    }
}

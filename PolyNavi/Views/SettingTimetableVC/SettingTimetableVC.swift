//
//  SettingTimetableVC.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 17.10.2021.
//

import UIKit

class SettingTimetableVC: UIViewController {
    
    private let itemsSegmentStrings: [String] = [L10n.Settings.titleOfGroupsView, L10n.Settings.titleOfTeachersView]
    
    private lazy var segmentControl: UISegmentedControl = {
        $0.selectedSegmentIndex = 0
        $0.addTarget(self, action: #selector(segmentChangeValueAction(_:)), for: .valueChanged)
        return $0
    }(UISegmentedControl(items: itemsSegmentStrings))
    
    private lazy var teacherView: TeachersSettingsView = {
        return $0
    }(TeachersSettingsView())
    
    private lazy var groupView: GroupsSettingsView = {
        return $0
    }(GroupsSettingsView())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .secondarySystemBackground
        
        self.navigationItem.title = L10n.Settings.title
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonAction(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonAction(_:)))
        
        setViews()
    }
    
}


//MARK:- Layout subviews
private extension SettingTimetableVC {
    func setViews() {
        [segmentControl, groupView, teacherView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        groupView.alpha = 1.0
        teacherView.alpha = 0.0
        
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentControl.heightAnchor.constraint(equalToConstant: 50),
            
            groupView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor),
            groupView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            groupView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            groupView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            teacherView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor),
            teacherView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            teacherView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            teacherView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}


//MARK:- Segment change value action
private extension SettingTimetableVC {
    @objc
    func segmentChangeValueAction(_ sender: UISegmentedControl) {
        let isFirstChoose = sender.selectedSegmentIndex == 0
        groupView.alpha = isFirstChoose ? 1.0 : 0.0
        teacherView.alpha = isFirstChoose ? 0.0 : 1.0
        if isFirstChoose {
            groupView.tableView.reloadData()
        }
    }
    
    @objc
    func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func doneButtonAction(_ sender: UIButton) {}
}


//MARK:- Group Delegate
extension SettingTimetableVC: NavigationSettingViewDelegate {
    func pushVC(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

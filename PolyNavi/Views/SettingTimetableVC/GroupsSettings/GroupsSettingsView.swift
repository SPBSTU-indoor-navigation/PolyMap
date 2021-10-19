//
//  GroupsSettingsView.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 17.10.2021.
//

import UIKit

protocol NavigationSettingViewDelegate {
    func pushVC(vc: UIViewController)
}

class GroupsSettingsView: UIView {
    
    private let cellID = "GroupCell"
    public var delegate: NavigationSettingViewDelegate?
    
    public lazy var tableView: UITableView = {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        return $0
    }(UITableView(frame: .zero, style: .insetGrouped))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.delegate = self
        tableView.dataSource = self
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setView() {
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
}


extension GroupsSettingsView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return L10n.Settings.settingOfGroup
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let textLabel = UILabel()
        textLabel.font = .preferredFont(forTextStyle: .headline)
        textLabel.text = (indexPath.row == 0) ? "\(L10n.Settings.titleOfInstituteCell): \(GroupsAndTeacherStorage.shared.getInstituteStringWithStatus())" : "\(L10n.Settings.titleOfInstituteCell): \(GroupsAndTeacherStorage.shared.getGroupStringWithStatus())"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.row == 0) {
            let vc = ChoosingWithSearchTableView()
            vc.loadFunction = { completion in
                TimetableProvider.shared.loadTeachers { result in
                    guard let response = result.data else { return }
                    completion(response.convert())
                }
            }
            self.delegate?.pushVC(vc: vc)
        } else {
            let vc = ChoosingWithSearchTableView()
            vc.loadFunction = { completion in
                TimetableProvider.shared.loadTeachers { result in
                    guard let response = result.data else { return }
                    completion(response.convert())
                }
            }
            self.delegate?.pushVC(vc: vc)
        }
    }
}

//
//  MapViewController.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 14.10.2021.
//

import UIKit

class MapViewController: UIViewController {
    private lazy var button: RoundButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.setTitle(L10n.Timetable.title, for: .normal)
        $0.setImage(UIImage(systemName: "calendar"), for: .normal)
        
        $0.setTitleColor(.white, for: .normal)
        $0.tintColor = .white

        $0.titleLabel?.adjustsFontForContentSizeCategory = true
        $0.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        $0.backgroundColor = .systemGray3
        
        $0.addTarget(self, action: #selector(openTimetableButtonTap(_:)), for: .touchUpInside)
        return $0
    }(RoundButton(type: .system))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        self.view.backgroundColor = .secondarySystemBackground
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(container)
        container.addSubview(button)
        
        
        NSLayoutConstraint.activate([
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            container.widthAnchor.constraint(equalTo: button.widthAnchor),
            container.topAnchor.constraint(equalTo: button.topAnchor),
            button.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
        ])

    }
    
    func openTimetable() {
        
        var vc: UIViewController
        
        if GroupsAndTeacherStorage.shared.isReady() {
            vc = TimetableViewController()
            vc.isModalInPresentation = true
        } else {
            let settings = SettingTimetableVC()
            settings.finishAction = { [weak self] in
                if GroupsAndTeacherStorage.shared.isReady() {
                    self?.openTimetable()
                }
            }
            vc = settings
        }
        
        let navSettingVC = UINavigationController(rootViewController: vc)
        self.present(navSettingVC, animated: true)
        
        

    }
    
    @objc
    func openTimetableButtonTap(_ sender: UIButton) {
        openTimetable()
    }
    
    
}

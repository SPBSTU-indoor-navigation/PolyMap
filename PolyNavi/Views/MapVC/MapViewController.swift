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
        
        $0.titleLabel?.adjustsFontForContentSizeCategory = true
        $0.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        
        $0.addTarget(self, action: #selector(openTimetable(_:)), for: .touchUpInside)
        return $0
    }(RoundButton(type: .system))
    
    private lazy var mapView: MapView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(MapView())
    
    private lazy var bottomSheetVC: BottomSheetViewController = {
        $0.view.clipsToBounds = false
        $0.view.layer.masksToBounds = false
        return $0
    }(BottomSheetViewController(parentVC: self, rootViewController: SearchVC()))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        addChild(bottomSheetVC)
        view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)
    }
    
    func setupViews() {
        self.view.backgroundColor = .secondarySystemBackground
        
        let container: UIView = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.addSubview(button)
            return $0
        }(UIView())
        
        view.addSubview(mapView)
        view.addSubview(container)
        
        
        NSLayoutConstraint.activate([
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            container.widthAnchor.constraint(equalTo: button.widthAnchor),
            container.topAnchor.constraint(equalTo: button.topAnchor),
            button.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

    }
    
    
    @objc
    func openTimetable(_ sender: UIButton?) {
        var vc: UIViewController
        
        if GroupsAndTeacherStorage.shared.isReady() {
            vc = TimetablePageVC()
            vc.isModalInPresentation = true
        } else {
            let settings = SettingTimetableVC()
            settings.finishAction = { [weak self] in
                if GroupsAndTeacherStorage.shared.isReady() {
                    self?.openTimetable(nil)
                }
            }
            vc = settings
        }
        
        let navSettingVC = UINavigationController(rootViewController: vc)
        self.present(navSettingVC, animated: true)
    }
    
}

//
//  MapViewController.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 14.10.2021.
//

import UIKit

class MapViewController: UIViewController {
    var timeTableSmallOffset: NSLayoutConstraint?
    
    private lazy var button: RoundButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.setTitle(L10n.Timetable.title, for: .normal)
        $0.setImage(UIImage(systemName: "calendar"), for: .normal)
        
        $0.titleLabel?.adjustsFontForContentSizeCategory = true
        $0.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        $0.addShadow()
        $0.addTarget(self, action: #selector(openTimetable(_:)), for: .touchUpInside)
        return $0
    }(RoundButton(type: .system))
    
    private lazy var timeTableSmallButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.tintColor = .secondaryLabel
        $0.setImage(UIImage(systemName: "calendar"), for: .normal)
        $0.setTitle(L10n.Timetable.title, for: .normal)
        $0.addTarget(self, action: #selector(openTimetable(_:)), for: .touchUpInside)
        
        if #available(iOS 15.0, *) {
            $0.configuration = .plain()
            $0.configuration?.contentInsets.leading = 4
            $0.configuration?.contentInsets.trailing = 8
        } else {
            $0.imageEdgeInsets = UIEdgeInsets(top: -3, left: -3, bottom: -3, right: -3)
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 8)
            $0.setTitleColor(.secondaryLabel, for: .normal)
        }
        
        $0.layer.cornerRadius = 8
        $0.layer.cornerCurve = .continuous
        $0.addShadow()
        $0.insertSubview(MapViewController.createBlur(), belowSubview: $0.imageView!)
        return $0
    }(UIButton())
    
    private lazy var mapView: MapView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(MapView())
    
    private lazy var mapInfo: MapInfo = {
        $0.view.clipsToBounds = false
        $0.view.layer.masksToBounds = false
        $0.bottomSheetDelegate = self
        return $0
    }(MapInfo(parentVC: self, rootViewController: SearchVC()))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        timeTableSmallOffset?.constant = mapInfo.position(for: .medium) + MapView.Constants.horizontalOffset
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
        mapInfo.safeZone.addSubview(timeTableSmallButton)
        
        addChild(mapInfo)
        view.addSubview(mapInfo.view)
        mapInfo.didMove(toParent: self)
        
        timeTableSmallOffset = timeTableSmallButton.bottomAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 0)
        NSLayoutConstraint.activate([
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            container.widthAnchor.constraint(equalTo: button.widthAnchor),
            container.topAnchor.constraint(equalTo: button.topAnchor),
            button.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            timeTableSmallButton.heightAnchor.constraint(equalToConstant: 35),
            timeTableSmallButton.trailingAnchor.constraint(equalTo: mapInfo.view.trailingAnchor, constant: MapView.Constants.horizontalOffset),
            timeTableSmallButton.bottomAnchor.constraint(greaterThanOrEqualTo: mapInfo.safeZone.bottomAnchor, constant: MapView.Constants.horizontalOffset),
            timeTableSmallOffset!
        ])
        
    }
    
    @objc
    func openTimetable(_ sender: UIButton?) {
        
#if !APPCLIP
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
#else
        TimeTableError().present(to: self, animated: true)
#endif
    }
    
    static func createBlur() -> UIVisualEffectView {
        let blur: UIVisualEffectView = {
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 8
            $0.layer.cornerCurve = .continuous
            
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.isUserInteractionEnabled = false
            return $0
        }(UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial)))
        return blur
    }
    
}

extension MapViewController: BottomSheetDelegate {
    func onSizeChange(from: BottomSheetViewController.HorizontalSize?, to: BottomSheetViewController.HorizontalSize) {
        timeTableSmallButton.isHidden = to != .big
    }
}

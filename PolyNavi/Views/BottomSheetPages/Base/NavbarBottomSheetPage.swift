//
//  NavbarBottomSheetPage.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.02.2022.
//

import UIKit

class NavbarBottomSheetPage: BluredBackgroundBottomSheetPage {
    var navbarHeight: CGFloat = 70.0 {
        didSet {
            navbarHeightConstraint?.constant = navbarHeight
            additionalSafeAreaInsets = UIEdgeInsets(top: navbarHeight, left: 0, bottom: 0, right: 0)
        }
    }
    
    private var closable: Bool = false
    private var navbarHeightConstraint: NSLayoutConstraint?
    
    let navbar: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    let contentView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    let navbarSeparator: UIView = {
        $0.backgroundColor = .separator
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alpha = 0
        return $0
    }(UIView())
    
    lazy var closeButton: UIButton = {
        $0.addTarget(self, action: #selector(closeButtonTap(_:)), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIButton(type: .close))
    
    init(closable: Bool = false, maximizationByNavbarClick: Bool = true) {
        super.init(nibName: nil, bundle: nil)
        
        self.closable = closable
        
        if maximizationByNavbarClick {
            let tap = UITapGestureRecognizer(target: self, action: #selector(navbarTap))
            navbar.addGestureRecognizer(tap)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navbar.addSubview(navbarSeparator)
        background.addSubview(navbar)
        background.addSubview(contentView)
        
        if closable {
            navbar.addSubview(closeButton)
            NSLayoutConstraint.activate([
                closeButton.centerYAnchor.constraint(equalTo: navbar.centerYAnchor),
                closeButton.trailingAnchor.constraint(equalTo: navbar.trailingAnchor, constant: -15)
            ].priority(.defaultLow))
            
            NSLayoutConstraint.activate([
                closeButton.widthAnchor.constraint(equalToConstant: 30),
                closeButton.heightAnchor.constraint(equalToConstant: 30),
            ])
        }
        
        navbarHeightConstraint = navbar.heightAnchor.constraint(equalToConstant: navbarHeight)
        NSLayoutConstraint.activate([
            navbarHeightConstraint!,
            
            navbarSeparator.heightAnchor.constraint(equalToConstant: 1),
            navbarSeparator.trailingAnchor.constraint(equalTo: navbar.trailingAnchor),
            navbarSeparator.leadingAnchor.constraint(equalTo: navbar.leadingAnchor),
            navbarSeparator.bottomAnchor.constraint(equalTo: navbar.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: navbar.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: background.bottomAnchor)
        ].priority(.defaultLow))
        
        NSLayoutConstraint.activate([
            navbar.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            navbar.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            navbar.topAnchor.constraint(equalTo: background.topAnchor)
        ].priority(.required))
        
        additionalSafeAreaInsets = UIEdgeInsets(top: navbarHeight, left: 0, bottom: 0, right: 0)
    }
    
    private var lastProgress: CGFloat = 0
    func update(progress: CGFloat) {
        lastProgress = progress
        navbarSeparator.alpha = lastProgress.clamped(0, 1) * contentView.alpha
    }
    
    func nextStateAfterTap(current: BottomSheetViewController.VerticalSize) -> BottomSheetViewController.VerticalSize? {
        switch current {
        case .small: return .medium
        case .medium: return .big
        default: return nil
        }
    }
    
    @objc
    private func navbarTap(_ sender: UIButton?) {
        let verticalSize = delegate?.verticalSize() ?? .small
        
        let targetSize = nextStateAfterTap(current: verticalSize)
        
        if let targetSize = targetSize,
           targetSize != verticalSize {
            delegate?.change(verticalSize: targetSize, animated: true)
        }
    }
    
    @objc
    private func closeButtonTap(_ sender: UIButton?) {
        close()
    }
    
    func close() {
        beforeClose()
        navigationController?.popViewController(animated: true)
    }
    
    func beforeClose() { }
    
    override func onButtomSheetScroll(progress: CGFloat) {
        super.onButtomSheetScroll(progress: progress)
        let limit = 0.9
        if progress > limit {
            changeContentAlpha(1 - (progress - limit) / (1 - limit))
            update(progress: lastProgress)
        } else if contentView.alpha != 1 {
            changeContentAlpha(1)
            update(progress: lastProgress)
        }
    }
    
    func changeContentAlpha(_ alpha: CGFloat) {
        contentView.alpha = alpha
    }
}

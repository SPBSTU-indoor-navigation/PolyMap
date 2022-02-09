//
//  NavbarBottomSheetPage.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.02.2022.
//

import UIKit

class NavbarBottomSheetPage: BluredBackgroundBottomSheetPage {
    private var closable: Bool = false
    
    let navbar: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    let navbarSeparator: UIView = {
        $0.backgroundColor = .separator
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alpha = 0
        return $0
    }(UIView())
    
    private lazy var closeButton: UIButton = {
        $0.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIButton(type: .close))
    
    init(closable: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        
        self.closable = closable
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navbar.addSubview(navbarSeparator)
        background.addSubview(navbar)
        
        if closable {
            navbar.addSubview(closeButton)
            NSLayoutConstraint.activate([
                closeButton.topAnchor.constraint(equalTo: navbar.topAnchor, constant: 10),
                closeButton.trailingAnchor.constraint(equalTo: navbar.trailingAnchor, constant: -10)
            ])
        }
        
        NSLayoutConstraint.activate([
            navbar.heightAnchor.constraint(equalToConstant: 80),
            navbar.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            navbar.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            navbar.topAnchor.constraint(equalTo: background.topAnchor),
            
            navbarSeparator.heightAnchor.constraint(equalToConstant: 1),
            navbarSeparator.trailingAnchor.constraint(equalTo: navbar.trailingAnchor),
            navbarSeparator.leadingAnchor.constraint(equalTo: navbar.leadingAnchor),
            navbarSeparator.bottomAnchor.constraint(equalTo: navbar.bottomAnchor),
        ])
        
        additionalSafeAreaInsets = UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)
    }
    
    func update(progress: CGFloat) {
        navbarSeparator.alpha = max(0, min(1, progress))
    }

    
    @objc
    private func close(_ sender: UIButton?) {
        beforeClose()
        navigationController?.popViewController(animated: true)
    }
    
    func beforeClose() { }
}

//
//  RouteDetailVC.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 08.03.2022.
//

import UIKit
import MapKit

class SearchLine: UIView, UITextViewDelegate {
    
    lazy var backgroundView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
//        $0.backgroundColor = .systemGreen.withAlphaComponent(0.5)
        return $0
    }(UIButton())
    
    lazy var textField: UITextField = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        return $0
    }(UITextField())
    
    lazy var cancelButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("Cancel", for: .normal)
        
//        $0.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
        return $0
    }(UIButton())
    
    lazy var searchBar: UISearchBar = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsCancelButton = true
        $0.searchBarStyle = .minimal
        
        return $0
    }(UISearchBar())
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(backgroundView)
        backgroundView.addSubview(searchBar)
        backgroundView.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            cancelButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            cancelButton.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class RouteDetailVC: NavbarBottomSheetPage {
    enum State {
        case normal
        case from
        case to
    }
    
    static var toPoint: MKAnnotation?
    static var fromPoint: MKAnnotation?
    
    var mapViewDelegate: MapViewDelegate
    var from: MKAnnotation? = nil
    var to: MKAnnotation? = nil
    
    var state: State = .normal
    
    var pathID: UUID?
    
    init(closable: Bool = false, mapViewDelegate: MapViewDelegate) {
        self.mapViewDelegate = mapViewDelegate
        super.init(closable: closable)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "Маршрут"
        $0.font = .systemFont(ofSize: 29, weight: .bold)
        return $0
    }(UILabel())
    
    lazy var searchFrom: SearchLine = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.cancelButton.addTarget(self, action: #selector(tapFrom(_:)), for: .touchUpInside)
        return $0
    }(SearchLine())
    
    lazy var searchTo: SearchLine = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.cancelButton.addTarget(self, action: #selector(tapTo(_:)), for: .touchUpInside)
        return $0
    }(SearchLine())
    
    lazy var tableView: UITableView = {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.sectionFooterHeight = 0
        
        return $0
    }(UITableView(frame: .zero, style: .insetGrouped))
    
    var openFromConstraints: [NSLayoutConstraint] = []
    var openToConstraints: [NSLayoutConstraint] = []
    
    
    @objc
    func tapFrom(_ sender: UIButton?) {
        changeState(state: state == .normal ? .from : .normal)
    }
    
    @objc
    func tapTo(_ sender: UIButton?) {
        changeState(state: state == .normal ? .to : .normal)
    }
    
    func changeState(state: State, animated: Bool = true) {
        if self.state == state { return }
        
        let change = { [self] in
            if state == .normal {
                NSLayoutConstraint.deactivate(self.state == .from ? openFromConstraints : openToConstraints)
            } else {
                NSLayoutConstraint.activate(state == .from ? openFromConstraints : openToConstraints)
            }
            
            closeButton.alpha = state == .normal ? 1 : 0
            titleLabel.alpha = state == .normal ? 1 : 0
            
            searchFrom.alpha = state != .to ? 1 : 0
            searchTo.alpha = state != .from ? 1 : 0
            
            view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                change()
            })
        } else {
            change()
        }
        
        self.state = state
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.addSubview(tableView)
        
        navbar.addSubview(titleLabel)
        
        navbar.addSubview(searchFrom)
        navbar.addSubview(searchTo)
        
//        navbar.backgroundColor = .systemBlue.withAlphaComponent(0.5)
        navbar.clipsToBounds = true
        
        openFromConstraints = [
            navbar.heightAnchor.constraint(equalToConstant: 75),
            searchFrom.topAnchor.constraint(equalTo: navbar.topAnchor, constant: 20)
        ].priority(.required)
        
        openToConstraints = [
            navbar.heightAnchor.constraint(equalToConstant: 75),
            searchTo.topAnchor.constraint(equalTo: navbar.topAnchor, constant: 20)
        ].priority(.required)
        

        
        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(equalTo: tableView.wrapperView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -5),
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            
            searchFrom.heightAnchor.constraint(equalToConstant: 36),
            searchFrom.leadingAnchor.constraint(equalTo: tableView.wrapperView.leadingAnchor),
            searchFrom.trailingAnchor.constraint(equalTo: tableView.wrapperView.trailingAnchor),
            searchFrom.topAnchor.constraint(equalTo: navbar.topAnchor, constant: 65),
            
            searchTo.heightAnchor.constraint(equalToConstant: 36),
            searchTo.leadingAnchor.constraint(equalTo: tableView.wrapperView.leadingAnchor),
            searchTo.trailingAnchor.constraint(equalTo: tableView.wrapperView.trailingAnchor),
            searchTo.topAnchor.constraint(equalTo: navbar.topAnchor, constant: 101),
            
            closeButton.trailingAnchor.constraint(equalTo: tableView.wrapperView.trailingAnchor).withPriority(.defaultHigh),
            navbar.heightAnchor.constraint(equalToConstant: 165)
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navbar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: navbar.topAnchor, constant: 15).withPriority(.init(rawValue: 900))
        ])
    }
    
    func setFrom(_ annotation: MKAnnotation) {
        if let from = RouteDetailVC.fromPoint { mapViewDelegate.unpinAnnotation(from, animated: true) }
        mapViewDelegate.pinAnnotation(annotation, animated: true)

        from = annotation
        
        drawPath()
    }
    
    func setTo(_ annotation: MKAnnotation) {
        if let to = RouteDetailVC.toPoint { mapViewDelegate.unpinAnnotation(to, animated: true) }
        
        self.mapViewDelegate.pinAnnotation(annotation, animated: true)
        self.mapViewDelegate.deselectAnnotation(annotation, animated: true)
        
        
        to = annotation
        
        drawPath()
    }
    
    func drawPath() {
        guard let from = from ?? IMDFDecoder.defaultPathStartPoint,
              let to = to else { return }
        
        RouteDetailVC.fromPoint = from
        RouteDetailVC.toPoint = to
        
        if let pathID = pathID {
            mapViewDelegate.removePath(id: pathID)
        }
        
        [to, from].forEach({
            mapViewDelegate.pinAnnotation($0, animated: true)
        })
        
        let result = PathFinder.shared.findPath(from: from, to: to)
        
        if let result = result {
            pathID = mapViewDelegate.addPath(path: result.path)
        } else {
            pathID = nil
        }
    }
    
    override func beforeClose() {
        super.beforeClose()
        RouteDetailVC.toPoint = nil
        RouteDetailVC.fromPoint = nil
        
        DispatchQueue.main.async { [self] in
            [to, from].compactMap({ $0 }).forEach({
                mapViewDelegate.unpinAnnotation($0, animated: true)
            })
            
            if let pathID = pathID {
                if from == nil,
                   let from = IMDFDecoder.defaultPathStartPoint {
                    mapViewDelegate.unpinAnnotation(from, animated: true)
                }
                
                mapViewDelegate.removePath(id: pathID)
            }
        }
        
    }
}


extension RouteDetailVC: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
}

extension RouteDetailVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = "\(indexPath.row)"
        
        return cell
        
    }
    
    
}

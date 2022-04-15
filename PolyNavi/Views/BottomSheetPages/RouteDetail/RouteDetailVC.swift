//
//  RouteDetailVC.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 08.03.2022.
//

import UIKit
import MapKit

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
    
    var searchable: [Searchable] = [] {
        didSet {
            searchTableView.searchable = searchable
        }
    }
    
    init(closable: Bool = false, mapViewDelegate: MapViewDelegate, searchable: [Searchable]) {
        self.mapViewDelegate = mapViewDelegate
        super.init(closable: closable)
        
        self.searchable = searchable
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.text = "Маршрут"
        $0.font = .systemFont(ofSize: 29, weight: .bold)
        return $0
    }(UILabel())
    
    let separator: UIView = {
        $0.backgroundColor = .separator
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alpha = 1
        return $0
    }(UIView())
    
    lazy var searchFrom: SearchLine = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.maskCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.titleLabel.text = "From:"
        $0.endEditing = cancelEditing
        $0.didChange = { str in self.onSearchEdit(from: .to, text: str)}
        $0.beginEditing = { str in
            self.beginEditing(state: .from)
            self.searchTableView.proccesSearcheble(searchText: str, force: true)
        }
        
        return $0
    }(SearchLine())
    
    lazy var searchTo: SearchLine = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.maskCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        $0.titleLabel.text = "To:"
        $0.endEditing = cancelEditing
        $0.didChange = { str in self.onSearchEdit(from: .to, text: str)}
        $0.beginEditing = { str in
            self.beginEditing(state: .to)
            self.searchTableView.proccesSearcheble(searchText: str, force: true)
        }
        return $0
    }(SearchLine())
    
    
    lazy var container: OpacityHitTest = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(OpacityHitTest())
    
    lazy var tableView: UITableView = {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.sectionFooterHeight = 0
        return $0
    }(UITableView(frame: .zero, style: .insetGrouped))
    
    lazy var searchTableView: SearchTableView = {
        $0.searchTableViewDelegate = self
        $0.searchable = searchable
        $0.alpha = 0
        $0.isHidden = true
        return $0
    }(SearchTableView(frame: .zero, style: .grouped))
    
    var openFromConstraints: [NSLayoutConstraint] = []
    var openToConstraints: [NSLayoutConstraint] = []
    
    func beginEditing(state: State) {
        delegate?.change(verticalSize: .big, animated: true)
        changeState(state: state)
    }
    
    func cancelEditing() {
        self.changeState(state: .normal)
        if delegate?.horizontalSize() == .big && delegate?.verticalSize() == .big {
            delegate?.change(verticalSize: .medium, animated: true)
        }
    }
    
    func changeState(state: State) {
        if self.state == state { return }
        searchTableView.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: { [self] in
            if state == .normal {
                NSLayoutConstraint.deactivate(self.state == .from ? openFromConstraints : openToConstraints)
            } else {
                NSLayoutConstraint.activate(state == .from ? openFromConstraints : openToConstraints)
            }
            
            let normalEnable = state == .normal ? 1.0 : 0.0
            
            closeButton.alpha = normalEnable
            titleLabel.alpha = normalEnable
            separator.alpha = normalEnable
            tableView.alpha = normalEnable
            
            searchFrom.alpha = state != .to ? 1 : 0
            searchTo.alpha = state != .from ? 1 : 0
            
            searchTableView.alpha = state != .normal ? 1 : 0
            
            view.layoutIfNeeded()
        }, completion: { _ in
            if state == .to { self.searchTo.textField.selectAll(nil) }
            if state == .from { self.searchFrom.textField.selectAll(nil) }
            self.searchTableView.isHidden = state == .normal
        })
        
        self.state = state
    }
    
    override func onButtomSheetScroll(progress: CGFloat) {
        super.onButtomSheetScroll(progress: progress)
        if searchFrom.isEditing { searchFrom.endEditing(true) }
        if searchTo.isEditing { searchTo.endEditing(true) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.addSubview(tableView)
        contentView.addSubview(searchTableView)
        
        container.addSubview(searchFrom)
        container.addSubview(searchTo)
        container.addSubview(separator)
        
        navbar.addSubview(titleLabel)
        navbar.insertSubview(container, aboveSubview: titleLabel)
        
        openFromConstraints = [
            navbar.heightAnchor.constraint(equalToConstant: 75),
            searchFrom.topAnchor.constraint(equalTo: navbar.topAnchor, constant: 17),
            searchFrom.heightAnchor.constraint(equalToConstant: 36)
        ].priority(.required)
        
        openToConstraints = [
            navbar.heightAnchor.constraint(equalToConstant: 75),
            searchTo.topAnchor.constraint(equalTo: navbar.topAnchor, constant: 17),
            searchTo.heightAnchor.constraint(equalToConstant: 36)
        ].priority(.required)
        
        
        NSLayoutConstraint.activate([
            
            container.leadingAnchor.constraint(equalTo: navbar.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: navbar.trailingAnchor),
            container.topAnchor.constraint(equalTo: navbar.topAnchor),
            container.bottomAnchor.constraint(equalTo: navbar.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: tableView.wrapperView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -5),
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            
            searchFrom.heightAnchor.constraint(equalToConstant: 40),
            searchFrom.leadingAnchor.constraint(equalTo: tableView.wrapperView.leadingAnchor),
            searchFrom.trailingAnchor.constraint(equalTo: tableView.wrapperView.trailingAnchor),
            searchFrom.topAnchor.constraint(equalTo: navbar.topAnchor, constant: 60),
            
            searchTo.heightAnchor.constraint(equalToConstant: 40),
            searchTo.leadingAnchor.constraint(equalTo: tableView.wrapperView.leadingAnchor),
            searchTo.trailingAnchor.constraint(equalTo: tableView.wrapperView.trailingAnchor),
            searchTo.topAnchor.constraint(equalTo: navbar.topAnchor, constant: 100),
            
            separator.centerYAnchor.constraint(equalTo: navbar.topAnchor, constant: 100),
            separator.leadingAnchor.constraint(equalTo: searchFrom.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: searchFrom.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),
            
            closeButton.trailingAnchor.constraint(equalTo: tableView.wrapperView.trailingAnchor).withPriority(.defaultHigh),
            navbar.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navbar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            
            searchTableView.topAnchor.constraint(equalTo: navbar.bottomAnchor),
            searchTableView.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            
            closeButton.topAnchor.constraint(equalTo: navbar.topAnchor, constant: 15).withPriority(.init(rawValue: 900))
        ])
    }
    
    func onSearchEdit(from state: State, text: String) {
        searchTableView.proccesSearcheble(searchText: text)
    }
    
    override func changeContentAlpha(_ alpha: CGFloat) {
        super.changeContentAlpha(alpha)
        
        container.alpha = alpha
    }
    
    override func onStateChange(verticalSize: BottomSheetViewController.VerticalSize) {
        super.onStateChange(verticalSize: verticalSize)
        if verticalSize == .small {
            if searchFrom.isSearch { searchFrom.isSearch = false }
            if searchTo.isSearch { searchTo.isSearch = false }
            changeState(state: .normal)
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

extension RouteDetailVC: SearchTableViewDelegate {
    func searchTableWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging(scrollView)
    }
    
    func searchTableDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
        update(progress: scrollView.topContentOffset.y / 20)
    }
    
    func searchTableWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    func searchTable(didSelect searchable: Searchable) {
        let annotation = searchable as? MKAnnotation
        
        if state == .to {
            if let annotation = annotation { setTo(annotation) }
            searchTo.endSearch()
        } else if state == .from {
            if let annotation = annotation { setFrom(annotation) }
            searchFrom.endSearch()
        }
    }
}


extension RouteDetailVC: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
        update(progress: scrollView.topContentOffset.y / 20)
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


extension RouteDetailVC {
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
        
        
        if let searchable = from as? Searchable {
            searchFrom.setup(text: searchable.mainTitle ?? "")
        }
        
        if let searchable = to as? Searchable {
            searchTo.setup(text: searchable.mainTitle ?? "")
        }
        
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
    
}

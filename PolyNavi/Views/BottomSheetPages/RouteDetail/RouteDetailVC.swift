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
    var routeParams: RouteParameters = .init(asphalt: false, serviceRoute: false) //TODO: Safe to user defaults
    var beforeCloseCompleate = false
    
    var routeDetailInfo: RouteDetailInfo? {
        didSet {
            tableView.dataSource = routeDetailInfo
        }
    }
    
    var state: State = .normal
    var focusAfterChangeSize: PathResult? = nil // В фуллсайзе не фокусирвовать, а только после изменения
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
        $0.text = L10n.MapInfo.Route.Info.title
        $0.font = .systemFont(ofSize: 29, weight: .bold)
        return $0
    }(UILabel())
    
    let separator: UIView = {
        $0.backgroundColor = .separator
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alpha = 1
        return $0
    }(UIView())
    
    lazy var changeDirection: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        $0.backgroundColor = Asset.Colors.bottomSheetGroupped.color
        $0.layer.cornerRadius = 45 / 2
        $0.addTarget(self, action: #selector(changeDirectionTap(_:)), for: .touchUpInside)
        return $0
    }(UIButton())
    
    lazy var searchFrom: SearchLine = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.maskCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.titleLabel.text = L10n.MapInfo.Route.Info.from
        $0.endEditing = cancelEditing
        $0.didChange = { str in self.onSearchEdit(from: .from, text: str)}
        $0.beginEditing = { str in self.beginEditing(state: .from, text: str) }
        
        return $0
    }(SearchLine())
    
    lazy var searchTo: SearchLine = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.maskCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        $0.titleLabel.text = L10n.MapInfo.Route.Info.to
        $0.endEditing = cancelEditing
        $0.didChange = { str in self.onSearchEdit(from: .to, text: str)}
        $0.beginEditing = { str in self.beginEditing(state: .to, text: str) }
        return $0
    }(SearchLine())
    
    
    lazy var container: OpacityHitTest = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(OpacityHitTest())
    
    lazy var tableView: UITableView = {
        $0.delegate = self
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.estimatedSectionFooterHeight = 0
        RouteDetailInfo.register(tableView: $0)
        return $0
    }(UITableView(frame: .zero, style: .insetGrouped))
    
    lazy var searchTableView: RouteDetailSearchTableView = {
        $0.searchTableViewDelegate = self
        $0.searchable = searchable
        $0.alpha = 0
        $0.isHidden = true
        return $0
    }(RouteDetailSearchTableView(frame: .zero, style: .grouped))
    
    override func nextStateAfterTap(current: BottomSheetViewController.VerticalSize) -> BottomSheetViewController.VerticalSize? {
        if state == .normal {
            return super.nextStateAfterTap(current: current)
        }
        return nil
    }
    
    var openFromConstraints: [NSLayoutConstraint] = []
    var openToConstraints: [NSLayoutConstraint] = []
    var verticalSizeBeforeSearch: BottomSheetViewController.VerticalSize?
    
    func beginEditing(state: State, text: String) {
        if self.state != .normal && self.state != state {
            DispatchQueue.main.async { [self] in
                searchFrom.endSearch()
                searchTo.endSearch()
                
                changeState(state: .normal)
            }
        } else {
            verticalSizeBeforeSearch = delegate?.verticalSize()
            delegate?.change(verticalSize: .big, animated: true)
            changeState(state: state)
            searchTableView.proccesSearcheble(searchText: text, force: true)
        }
    }
    
    func cancelEditing() {
        self.changeState(state: .normal)
        if delegate?.horizontalSize() == .big && delegate?.verticalSize() == .big {
            let size = verticalSizeBeforeSearch ?? .medium
            delegate?.change(verticalSize: size != .small ? size : .medium, animated: true)
        }
    }
    
    func changeState(state: State) {
        if self.state == state { return }
        
        if state != .normal {
            searchTableView.skipSearchable = (state == .from ? searchTo.searchable : searchFrom.searchable)
        }
        
        searchTableView.isHidden = false
        let normalEnable = state == .normal ? 1.0 : 0.0
        
        if state == .normal {
            UIView.animate(withDuration: 0.1, delay: 0.2, options: .curveEaseInOut, animations: { [self] in
                changeDirection.alpha = 1
                changeDirection.transform = .one
            })
        } else {
            UIView.animate(withDuration: 0.1, animations: { [self] in
                changeDirection.alpha = 0
                changeDirection.transform = .one.scaled(scale: 0.7)
            })
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: { [self] in
            if state == .normal {
                NSLayoutConstraint.deactivate(self.state == .from ? openFromConstraints : openToConstraints)
            } else {
                NSLayoutConstraint.activate(state == .from ? openFromConstraints : openToConstraints)
            }
            
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
            
            if state == .normal {
                self.searchTo.isEditing = false
                self.searchFrom.isEditing = false
            }
        })
        
        self.state = state
    }
    
    var changeDirectionAnimate = false
    
    @objc
    func changeDirectionTap(_ sender: UIButton?) {
        if changeDirectionAnimate { return }
        
        changeDirectionAnimate = true
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [self] in
            changeDirection.imageView?.transform = CGAffineTransform(rotationAngle: .pi)
            
            let delta = searchFrom.titleLabel.frame.maxX - searchTo.titleLabel.frame.maxX
            searchTo.textField.transform = CGAffineTransform(translationX: delta, y: -40)
            searchFrom.textField.transform = CGAffineTransform(translationX: -delta, y: 40)
        }, completion: { _ in
            self.changeDirection.imageView?.transform = .identity
            self.searchFrom.textField.transform = .identity
            self.searchTo.textField.transform = .identity
            
            swap(&self.from, &self.to)
            self.drawPath()
            
            self.changeDirectionAnimate = false
        })
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
        container.addSubview(changeDirection)
        
        navbar.addSubview(titleLabel)
        navbar.insertSubview(container, aboveSubview: titleLabel)
        
        openFromConstraints = [
            navbar.heightAnchor.constraint(equalToConstant: 70),
            searchFrom.topAnchor.constraint(equalTo: navbar.topAnchor, constant: 17),
            searchFrom.heightAnchor.constraint(equalToConstant: 36)
        ].priority(.required)
        
        openToConstraints = [
            navbar.heightAnchor.constraint(equalToConstant: 70),
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
            
            searchFrom.heightAnchor.constraint(equalToConstant: 40).withPriority(.defaultHigh),
            searchFrom.leadingAnchor.constraint(equalTo: tableView.wrapperView.leadingAnchor),
            searchFrom.trailingAnchor.constraint(equalTo: tableView.wrapperView.trailingAnchor),
            searchFrom.topAnchor.constraint(equalTo: navbar.topAnchor, constant: 60).withPriority(.defaultHigh),
            
            searchTo.heightAnchor.constraint(equalToConstant: 40).withPriority(.defaultHigh),
            searchTo.leadingAnchor.constraint(equalTo: tableView.wrapperView.leadingAnchor),
            searchTo.trailingAnchor.constraint(equalTo: tableView.wrapperView.trailingAnchor),
            searchTo.topAnchor.constraint(equalTo: navbar.topAnchor, constant: 100).withPriority(.defaultHigh),
            
            separator.centerYAnchor.constraint(equalTo: navbar.topAnchor, constant: 100),
            separator.leadingAnchor.constraint(equalTo: searchFrom.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: searchFrom.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),
            
            closeButton.trailingAnchor.constraint(equalTo: tableView.wrapperView.trailingAnchor).withPriority(.defaultHigh),
            navbar.heightAnchor.constraint(equalToConstant: 155).withPriority(.defaultHigh)
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navbar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            
            searchTableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            searchTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            changeDirection.widthAnchor.constraint(equalToConstant: 45),
            changeDirection.heightAnchor.constraint(equalToConstant: 45),
            changeDirection.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -25),
            changeDirection.centerYAnchor.constraint(equalTo: separator.centerYAnchor),
            
            closeButton.topAnchor.constraint(equalTo: navbar.topAnchor, constant: 15).withPriority(.init(rawValue: 900))
        ])
        
        closeButton.becomeFirstResponder()
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
        
        if let result = focusAfterChangeSize,
           verticalSize != .big {
            DispatchQueue.main.async {
                self.mapViewDelegate.focus(on: result)
            }
            focusAfterChangeSize = nil
        }
    }
    
    override func beforeClose() {
        super.beforeClose()
        
        if beforeCloseCompleate { return }
        beforeCloseCompleate = true
        
        RouteDetailVC.toPoint = nil
        RouteDetailVC.fromPoint = nil
        focusAfterChangeSize = nil
        
        DispatchQueue.main.async { [self] in
            [to, from].compactMap({ $0 }).forEach({
                mapViewDelegate.unpinAnnotation($0, animated: true)
            })
            
            if let pathID = pathID {
                if from == nil,
                   let from = MapViewController.currentVenue?.defaultPathStartPoint {
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
            searchTo.endSearch()
            if let annotation = annotation { setTo(annotation) }
        } else if state == .from {
            searchFrom.endSearch()
            if let annotation = annotation { setFrom(annotation) }
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        routeDetailInfo?.delegateTV(tableView, viewForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        routeDetailInfo?.delegateTV(tableView, didSelectRowAt: indexPath)
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
    
    func setup(from: MKAnnotation, to: MKAnnotation, routeParams: RouteParameters) {
        if let from = RouteDetailVC.fromPoint { mapViewDelegate.unpinAnnotation(from, animated: true) }
        if let to = RouteDetailVC.toPoint { mapViewDelegate.unpinAnnotation(to, animated: true) }
        
        self.from = from
        self.to = to
        self.routeParams = routeParams
        
        mapViewDelegate.pinAnnotation(from, animated: true)
        mapViewDelegate.pinAnnotation(to, animated: true)
        self.mapViewDelegate.deselectAnnotation(from, animated: true)
        self.mapViewDelegate.deselectAnnotation(to, animated: true)
        
        if let routeDetailInfo = routeDetailInfo {
            routeDetailInfo.routeParams = routeParams
            self.tableView.reloadData()
        } else {
            drawPath()
        }
    }
    
    func drawPath() {
        from = from ?? MapViewController.currentVenue?.defaultPathStartPoint
        
        guard let from = from,
              let to = to else { return }
        
        
        RouteDetailVC.fromPoint = from
        RouteDetailVC.toPoint = to
        
        
        if let searchable = from as? Searchable {
            searchFrom.setup(searchable)
        }
        
        if let searchable = to as? Searchable {
            searchTo.setup(searchable)
        }
        
        if let pathID = pathID {
            mapViewDelegate.removePath(id: pathID)
        }
        
        [to, from].forEach({
            mapViewDelegate.pinAnnotation($0, animated: true)
        })
        
        let result = PathFinder.shared.findPath(from: from, to: to)
        
        if let routeDetailInfo = routeDetailInfo {
            routeDetailInfo.configurate(result: result, tableView: tableView)
        } else {
            routeDetailInfo = RouteDetailInfo(result: result, redrawPath: self.drawPath, routeParams: routeParams)
        }
        
                
        if let result = result {
            pathID = mapViewDelegate.addPath(path: result.path)
            
            if delegate?.horizontalSize() == .big && delegate?.verticalSize() == .big {
                self.focusAfterChangeSize = result
            } else {
                mapViewDelegate.focus(on: result)
            }
        } else {
            pathID = nil
        }
    }
    
}

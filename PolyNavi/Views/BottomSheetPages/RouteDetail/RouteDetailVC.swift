//
//  RouteDetailVC.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 08.03.2022.
//

import UIKit
import MapKit

class SearchLine: UIView, UITextFieldDelegate {
    
    var beginEditing: (() -> Void)?
    var endEditing: (() -> Void)?
    
    var maskCorners: CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] {
        didSet {
            containerView.layer.maskedCorners = maskCorners
        }
    }
    
    var isSearch = false {
        didSet {
            UIView.animate(withDuration: 0.25, animations: { [self] in
                if isSearch {
                    NSLayoutConstraint.activate(selectedConstraints)
                    backgroundView.layer.cornerRadius = 10
                } else {
                    NSLayoutConstraint.deactivate(selectedConstraints)
                    cancelButton.alpha = 0
                    backgroundView.layer.cornerRadius = 0
                }
                
                layoutIfNeeded()
            }, completion: { _ in
                if self.isSearch {
                    self.textField.clearButtonMode = .whileEditing
                }
            })
            
            if isSearch {
                UIView.animate(withDuration: 0.1, animations: { [self] in
                    cancelButton.alpha = 1
                })
            }
            
            if !isSearch {
                self.textField.clearButtonMode = .never
            }
        }
    }
    
    var isEditing = false
    
    lazy var containerView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.layer.cornerCurve = .continuous
        return $0
    }(UIButton())
    
    lazy var backgroundView: UIView = {
        $0.layer.cornerCurve = .continuous
        $0.clipsToBounds = true
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        $0.backgroundColor = Asset.Colors.searchBarBackground.color
        return $0
    }(UIButton())
    
    lazy var textField: UITextField = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.placeholder = "Search"
        $0.delegate = self
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        $0.tintColor = Asset.accentColor.color
        $0.clearButtonMode = .never
        return $0
    }(UITextField())
    
    lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "From:"
        $0.textColor = .secondaryLabel
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return $0
    }(UILabel())
    
    lazy var cancelButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("Cancel", for: .normal)
        $0.setTitleColor(Asset.accentColor.color, for: .normal)
        $0.setTitleColor(Asset.accentColor.color.withAlphaComponent(0.8), for: .selected)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.alpha = 0
        
        $0.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
        return $0
    }(UIButton())
    
    var selectedConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(containerView)
        addSubview(cancelButton)
        containerView.addSubview(backgroundView)
        backgroundView.addSubview(textField)
        backgroundView.addSubview(titleLabel)
        
        
        selectedConstraints = [
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ].priority(.required)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -10),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor).withPriority(.defaultHigh),
            
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor).withPriority(.defaultLow),
            cancelButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            textField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 5),
    
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 8),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func cancel(_ sender: UIButton?) {
        isSearch = false
        textField.endEditing(true)
        endEditing?()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isSearch = true
        beginEditing?()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isEditing = false
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
        $0.beginEditing = {
            self.beginEditing(state: .from)
        }
        
        return $0
    }(SearchLine())
    
    lazy var searchTo: SearchLine = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.maskCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        $0.titleLabel.text = "To:"
        $0.endEditing = cancelEditing
        $0.beginEditing = {
            self.beginEditing(state: .to)
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
        
        UIView.animate(withDuration: 0.25, animations: { [self] in
            if state == .normal {
                NSLayoutConstraint.deactivate(self.state == .from ? openFromConstraints : openToConstraints)
            } else {
                NSLayoutConstraint.activate(state == .from ? openFromConstraints : openToConstraints)
            }
            
            closeButton.alpha = state == .normal ? 1 : 0
            titleLabel.alpha = state == .normal ? 1 : 0
            separator.alpha = state == .normal ? 1 : 0
            
            searchFrom.alpha = state != .to ? 1 : 0
            searchTo.alpha = state != .from ? 1 : 0
            
            view.layoutIfNeeded()
       })
        
        self.state = state
    }
    
    var lastProgress: CGFloat = 0
    override func onButtomSheetScroll(progress: CGFloat) {
        super.onButtomSheetScroll(progress: progress)
        if lastProgress != progress {
            lastProgress = progress
            if state != .normal {
                searchFrom.endEditing(true)
                searchTo.endEditing(true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.addSubview(tableView)
        
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
            closeButton.topAnchor.constraint(equalTo: navbar.topAnchor, constant: 15).withPriority(.init(rawValue: 900))
        ])
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

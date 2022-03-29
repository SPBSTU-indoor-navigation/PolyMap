//
//  TodayTableViewCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 27.03.2022.
//

import UIKit

class TodayTableViewCell: UITableViewCell {
    static var identifier: String = String(describing: TodayTableViewCell.self)
    
    let stripLayout = FlowLayout(layoutType: .strip)
    let listLayout = FlowLayout(layoutType: .list)
    
    var isExpanded = false
    
    private var heightConstraint: NSLayoutConstraint!
    private var tableView: UITableView?
    
    lazy var collection: UICollectionView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.dataSource = self
        $0.delegate = self
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.register(TodayCollectionCell.self, forCellWithReuseIdentifier: TodayCollectionCell.identifier)
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: stripLayout))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        backgroundColor = Asset.Colors.bottomSheetGroupped.color    
        listLayout.sizeForListItemAt = { [weak self] indexPath in
            return CGSize(width: self?.collection.frame.width ?? 100, height: 100)
        }
        
        stripLayout.sizeForStripItemAt = { indexPath in
            return CGSize(width: 100, height: 150)
        }
        
        heightConstraint = collection.heightAnchor.constraint(equalToConstant: 150)
        
        contentView.addSubview(collection)
        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: contentView.topAnchor),
            collection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heightConstraint,
            contentView.bottomAnchor.constraint(equalTo: collection.bottomAnchor)
        ])
        
    }
    
    func configurate(tableView: UITableView) {
        self.tableView = tableView
    }
}

extension TodayTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayCollectionCell.identifier, for: indexPath) as! TodayCollectionCell
        
        cell.changeLayout(layoutType: isExpanded ? .list : .strip, animated: false)
        
        return cell
    }
}

extension TodayTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        isExpanded.toggle()
        
        heightConstraint.constant = self.isExpanded ? CGFloat(collectionView.numberOfItems(inSection: 0)) * 100.0 : 150
        tableView?.performBatchUpdates(nil)
        
        collection.setCollectionViewLayout(isExpanded ? listLayout : stripLayout, animated: true)
        
    }
}

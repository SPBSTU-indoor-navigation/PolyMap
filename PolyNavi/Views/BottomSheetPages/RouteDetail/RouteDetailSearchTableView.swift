//
//  RouteDetailSearchTableView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 16.04.2022.
//

import UIKit

class RouteDetailSearchTableView: SearchTableView {
    
    var skipSearchable: Searchable? = nil {
        didSet {
            proccesSearcheble(searchText: lastSearch, force: true)
        }
    }
    
    override func filter(searchText: String) -> [Searchable] {
        let res = super.filter(searchText: searchText)
        
        return res.filter({ !($0.annotation.isEqual(skipSearchable?.annotation)) })
    }
}

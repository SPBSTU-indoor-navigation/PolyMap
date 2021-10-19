//
//  ChoosingWithSearchTableView.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 19.10.2021.
//

import UIKit


class ChoosingWithSearchTableView: UIViewController {
    
    private var currentArray: [SettingsModel] = []
    private var filteredArray: [SettingsModel] = []
    public var choosingFunction: () -> Void = {}
    public var loadFunction: (@escaping ([SettingsModel]) -> Void) -> Void = { _ in  }
    
    private lazy var searchController: UISearchController = {
        $0.searchResultsUpdater = self
        $0.obscuresBackgroundDuringPresentation = false
        $0.searchBar.placeholder = L10n.ChoosingSearchController.searchPlaceholder
        return $0
    }(UISearchController(searchResultsController: nil))
    
    private lazy var tableView: UITableView = {
        $0.register(ChoosingTableViewCell.self, forCellReuseIdentifier: ChoosingTableViewCell.identifire)
        $0.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 5))
        $0.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        $0.showsVerticalScrollIndicator = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UITableView())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.searchController = searchController
        definesPresentationContext = true
        self.view.backgroundColor = .systemGroupedBackground
        tableView.delegate = self
        tableView.dataSource = self
        setViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
}


//MARK:- Delegate and datasource of tableView and update search
extension ChoosingWithSearchTableView: UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChoosingTableViewCell.identifire, for: indexPath) as? ChoosingTableViewCell else {
            return UITableViewCell()
        }
        let elem = currentArray[indexPath.row]
        cell.configure(title: elem.title, status: false)
        return cell
    }
    
}

extension ChoosingWithSearchTableView {
    
    private func setViews() {
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
}


extension ChoosingWithSearchTableView {
    func configureView() {
        
    }
    
    func loadData() {
        self.loadFunction { [weak self] arr in
            guard let self = self else {return}
            self.currentArray = arr
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
}

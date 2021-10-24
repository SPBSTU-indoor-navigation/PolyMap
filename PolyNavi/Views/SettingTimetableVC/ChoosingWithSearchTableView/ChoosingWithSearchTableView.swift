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
    public var choosingFunction: (SettingsModel) -> Void = { _ in }
    public var loadFunction: (@escaping ([SettingsModel]) -> Void) -> Void = { _ in  }
    public var selectedID: Int? = nil
    
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
        guard let text = searchController.searchBar.text else {
            filteredArray = currentArray
            self.tableView.reloadData()
            return
        }
        if text.isEmpty {
            filteredArray = currentArray
        } else {
            filteredArray = filteredArray.filter {
                $0.title.lowercased().contains(text.lowercased())
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChoosingTableViewCell.identifire, for: indexPath) as? ChoosingTableViewCell else {
            return UITableViewCell()
        }
        let elem = filteredArray[indexPath.row]
        if let index = selectedID {
            cell.configure(title: elem.title, status: elem.ID == index)
        } else {
            cell.configure(title: elem.title, status: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentIndex = selectedID,
           let indexInArray = self.filteredArray.firstIndex(where: {$0.ID == currentIndex}),
           let currentCell = tableView.cellForRow(at: IndexPath(row: indexInArray, section: 0)) as? ChoosingTableViewCell {
            currentCell.toogleCheckbox()
        }
        selectedID = filteredArray[indexPath.row].ID
        guard let cell = tableView.cellForRow(at: indexPath) as? ChoosingTableViewCell else {return}
        cell.toogleCheckbox()
        let element = filteredArray[indexPath.row]
        choosingFunction(element)
        tableView.deselectRow(at: indexPath, animated: true)
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
    func loadData() {
        self.loadFunction { [weak self] arr in
            guard let self = self else {return}
            self.currentArray = arr
            self.filteredArray = arr
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
}

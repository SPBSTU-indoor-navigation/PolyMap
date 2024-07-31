import UIKit

class BaseSearchCell: UITableViewCell {
    var separatorColor: UIColor = .separator {
        didSet {
            separator.backgroundColor = separatorColor
        }
    }
    
    lazy var separator: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = separatorColor
        return $0
    }(UIView())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() { }
    
    func configurate(searchable: Searchable) { }
}

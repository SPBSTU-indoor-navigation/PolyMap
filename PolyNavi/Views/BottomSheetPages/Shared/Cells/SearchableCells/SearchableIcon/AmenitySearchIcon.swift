import UIKit

class AmenitySearchIcon: OccupantSearchIcon {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconContainer.layer.cornerRadius = frame.width / 4
    }
}

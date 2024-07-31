import UIKit

class EnviromentAmenitySearchCell: AttractionSearchCell {
    lazy var iconAmenity: AmenitySearchIcon = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(AmenitySearchIcon())
    
    override var icon: UIView & SearchableConfigurate {
        return iconAmenity
    }
}

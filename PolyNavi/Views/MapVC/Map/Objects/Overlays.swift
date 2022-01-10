//
//  Objects.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 06.01.2022.
//

import MapKit


protocol Styleble {
    func configurate(renderer: MKOverlayRenderer)
}

protocol MapRenderer {
    func show(_ mapView: MKMapView)
    func hide(_ mapView: MKMapView)
}

class Opening: MKPolyline, Styleble {
    var type: IMDF.Opening.OpeningType = .unitDefault
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKPolylineRenderer else { return }
        switch type {
        case .stairs:
            renderer.strokeColor = Asset.IMDFColors.Units.stairs.color
            renderer.lineCap = .butt
        default: renderer.strokeColor = Asset.IMDFColors.Units.default.color
        }
        renderer.lineWidth = 4
    }
}

class Unit: MKMultiPolygon, Styleble {
    
    var annotation: UnitAnnotation? = nil
    var id: UUID
    var categoty: IMDF.Unit.Category
    
    init(_ polygons: [MKPolygon],
         id: UUID,
         displayPoint: CLLocationCoordinate2D?,
         name: LocalizedName?,
         altName: LocalizedName?,
         categoty: IMDF.Unit.Category) {
        
        self.id = id
        self.categoty = categoty
        
        if let displayPoint = displayPoint, let altName = altName {
            annotation = UnitAnnotation(coordinate: displayPoint, title: altName.bestLocalizedValue)
        }
        
        super.init(polygons)
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKMultiPolygonRenderer else { return }
        
        renderer.strokeColor = Asset.IMDFColors.Units.defaultLine.color
        renderer.lineWidth = 1
        
        
        switch categoty {
        case .restroom, .restroomFemale, .restroomMale:
            renderer.fillColor = Asset.IMDFColors.Units.restroom.color
        default:
            renderer.fillColor = UIColor(named: categoty.rawValue) ?? Asset.IMDFColors.Units.default.color
        }
        
        switch categoty {
//        case .stairs:
//            renderer.strokeColor = Asset.IMDFColors.Units.defaultLine.color.withAlphaComponent(0.5)
        default: break
        }
        
        
        
    }
}

class Level: MKMultiPolygon, Styleble, MapRenderer {
    private var isShow = false
    var units: [Unit] = []
    var openings: [Opening] = []
    var amenitys: [AmenityAnnotation] = []
    var ordinal: Int = 0
    var shortName: LocalizedName?
    
    init(_ polygons: [MKPolygon], ordinal: Int, units: [Unit], openings: [Opening], shortName: LocalizedName?, amenitys: [IMDF.Amenity] ) {
        super.init(polygons)
        self.ordinal = ordinal
        self.units = units
        self.openings = openings
        self.shortName = shortName
        self.amenitys = amenitys.map({ AmenityAnnotation(coordinate: ($0.geometry.first as! MKPointAnnotation).coordinate, category: $0.properties.category) })
        
        let amenityUnits = amenitys.flatMap({ $0.properties.unit_ids })
        
        for unit in self.units {
            if amenityUnits.contains(unit.id) {
                unit.annotation = nil
            }
        }
    }
    
    func show(_ mapView: MKMapView) {
        if isShow { return }
        mapView.addOverlays(units)
        mapView.addOverlays(openings)
        mapView.addOverlay(self)
        
        mapView.addAnnotations(units.compactMap{ $0.annotation })
        mapView.addAnnotations(amenitys)
        isShow = true
    }
    
    func hide(_ mapView: MKMapView) {
        if !isShow { return }
        mapView.removeOverlays(units)
        mapView.removeOverlays(openings)
        mapView.removeOverlay(self)
        
        mapView.removeAnnotations(units.compactMap({ $0.annotation }))
        mapView.removeAnnotations(amenitys)
        
        isShow = false
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKMultiPolygonRenderer else { return }
        renderer.fillColor = .clear
        renderer.lineWidth = 2
        renderer.strokeColor = Asset.IMDFColors.levelLine.color
    }
}

class Building: MKMultiPolygon, Styleble, MapRenderer {
    var levels: [Level] = []

    
    var ordinal = -1
    private var isShow = false
    
    init(_ polygons: [MKPolygon], levels: [Level]) {
        super.init(polygons)
        self.levels = levels
        self.ordinal = levels.map({ $0.ordinal }).min() ?? -1
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKMultiPolygonRenderer else { return }
        renderer.shouldRasterize = false
        renderer.strokeColor = Asset.IMDFColors.buildingLine.color
        renderer.lineWidth = isShow ? 0.001 : 1
        renderer.fillColor = (isShow && level(byOrdinal: ordinal) != nil) ? Asset.IMDFColors.buildingUnderLevel.color : Asset.IMDFColors.buildingFill.color
    }
    
    func changeOrdinal(_ ordinal: Int, _ mapView: MKMapView) {
        if self.ordinal == ordinal { return }
        
        if isShow {
            hide(mapView)
            self.ordinal = ordinal
            show(mapView)
        } else {
            self.ordinal = ordinal
        }
        
    }
    
    func show(_ mapView: MKMapView) {
        if isShow { return }
        isShow = true
        mapView.removeOverlay(self)
        mapView.addOverlay(self)
        
        if let level = level(byOrdinal: ordinal) {
            level.show(mapView)
        }
        
    }
    
    func hide(_ mapView: MKMapView) {
        if !isShow { return }
        isShow = false
        
        mapView.removeOverlay(self)
        mapView.addOverlay(self)
        
        if let level = level(byOrdinal: ordinal) {
            level.hide(mapView)
        }
        
    }
    
    
    private func level(byOrdinal: Int) -> Level? {
        return levels.first(where: { $0.ordinal == byOrdinal })
    }
    
}

class Venue: MKMultiPolygon, Styleble {
    
    var buildings: [Building] = []
    var address: IMDF.Address?
    
    override init(_ polygons: [MKPolygon]) {
        super.init(polygons)
    }
    
    init(geometry: [MKPolygon], buildings: [Building], address: IMDF.Address?) {
        super.init(geometry)
        self.buildings = buildings
        self.address = address
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKMultiPolygonRenderer else { return }
//        renderer.strokeColor = .red
//        renderer.lineWidth = 5
        renderer.fillColor = Asset.IMDFColors.venueFill.color
    }
}

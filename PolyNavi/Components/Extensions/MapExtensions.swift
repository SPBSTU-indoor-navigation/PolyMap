//
//  MapExtensions.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 07.01.2022.
//

import MapKit

extension CLLocationCoordinate2D {
    /// Returns distance from coordianate in meters.
    /// - Parameter from: coordinate which will be used as end point.
    /// - Returns: Returns distance in meters.
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: self.latitude, longitude: self.longitude)
        return from.distance(from: to)
    }
}

extension MapView {
    func getZoom() -> Float {
        // function returns current zoom of the map
        var angleCamera = getRotation()
        if angleCamera > 270 {
            angleCamera = 360 - angleCamera
        } else if angleCamera > 90 {
            angleCamera = fabs(angleCamera - 180)
        }
        let angleRad = Double.pi * angleCamera / 180 // map rotation in radians
        let width = Double(mapView.frame.size.width)
        let height = Double(mapView.frame.size.height)
        let heightOffset : Double = 20 // the offset (status bar height) which is taken by MapKit into consideration to calculate visible area height
        // calculating Longitude span corresponding to normal (non-rotated) width
        let spanStraight = width * mapView.region.span.longitudeDelta / (width * cos(angleRad) + (height - heightOffset) * sin(angleRad))
        return Float(log2(360 * ((width / 128) / spanStraight)))
    }
    
    func getRotation() -> Double {
        // function gets current map rotation based on the transform values of MKScrollContainerView
        var rotation = fabs(180 * asin(Double(self.mapContainerView!.transform.b)) / Double.pi)
        if self.mapContainerView!.transform.b <= 0 {
            if self.mapContainerView!.transform.a < 0 {
                rotation = 180 - rotation
            }
        } else {
            if self.mapContainerView!.transform.a <= 0 {
                rotation = rotation + 180
            } else {
                rotation = 360 - rotation
            }
        }
        return rotation
    }
}

extension MKPolygon {
    func contains(_ point: CLLocationCoordinate2D) -> Bool {
        let polygonRenderer = MKPolygonRenderer(polygon: self)
        let currentMapPoint: MKMapPoint = MKMapPoint(point)
        let polygonViewPoint: CGPoint = polygonRenderer.point(for: currentMapPoint)
        if polygonRenderer.path == nil {
            return false
        } else {
            return polygonRenderer.path.contains(polygonViewPoint)
        }
    }
    
    func contains(_ points: [CLLocationCoordinate2D]) -> Bool {
        let polygonRenderer = MKPolygonRenderer(polygon: self)
        
        if polygonRenderer.path == nil {
            return false
        } else {
            for point in points {
                if  polygonRenderer.path.contains(polygonRenderer.point(for: MKMapPoint(point))) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func intersection(p0: MKMapPoint, p1: MKMapPoint) -> Bool {
        func intersection(_ p0: MKMapPoint, _ p1: MKMapPoint, _ p2: MKMapPoint, _ p3: MKMapPoint) -> Bool {
            var denominator = (p3.x - p2.x) * (p1.y - p0.y) - (p3.y - p2.y) * (p1.x - p0.x)
            var ua = (p3.y - p2.y) * (p0.x - p2.x) - (p3.x - p2.x) * (p0.y - p2.y)
            var ub = (p1.y - p0.y) * (p0.x - p2.x) - (p1.x - p0.x) * (p0.y - p2.y)
            
            if (denominator < 0) {
                ua = -ua; ub = -ub; denominator = -denominator
            }
            
            return ua >= 0.0 && ua <= denominator && ub >= 0.0 && ub <= denominator && denominator != 0
        }
        
        if pointCount <= 2 { return false }
        
        let points = points()
        
        if intersection(p0, p1, points[0], points[pointCount-1]) { return true }
        
        for i in 1..<pointCount {
            if intersection(p0, p1, points[i-1], points[i]) { return true }
        }
        
        return false
    }
}

extension MKMapRect {
    init(points: [MKMapPoint]) {
        
        var minX: Double = Double.greatestFiniteMagnitude
        var minY: Double = Double.greatestFiniteMagnitude
        
        var maxX: Double = -Double.greatestFiniteMagnitude
        var maxY: Double = -Double.greatestFiniteMagnitude
        
        for point in points {
            minX = min(minX, point.x)
            minY = min(minY, point.y)
            
            maxX = max(maxX, point.x)
            maxY = max(maxY, point.y)
        }
        
        self.init(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

extension MKCoordinateRegion {
    func deltaInMeters() -> (Double, Double) {
        let loc1 = CLLocation(latitude: center.latitude - span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc2 = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc3 = CLLocation(latitude: center.latitude, longitude: center.longitude - span.longitudeDelta * 0.5)
        let loc4 = CLLocation(latitude: center.latitude, longitude: center.longitude + span.longitudeDelta * 0.5)
        
        let metersInLatitude = loc1.distance(from: loc2)
        let metersInLongitude = loc3.distance(from: loc4)
        
        return (metersInLatitude, metersInLongitude)
    }
}

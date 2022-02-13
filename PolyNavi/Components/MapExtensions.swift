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

extension UIView {
    func addShadow(shadowOpacity: Float = 0.2, shadowOffset: CGSize = .zero, shadowRadius: CGFloat = 5) {
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
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
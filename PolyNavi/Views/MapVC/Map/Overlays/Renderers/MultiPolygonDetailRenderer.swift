//
//  MultyPolygonDetailRenderer.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 19.01.2022.
//

import MapKit

class MultiPolylineDetailRenderer: MKMultiPolylineRenderer {

    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        
        let overlay = overlay as! MKMultiPolyline;
        
        context.saveGState()
        context.setStrokeColor(strokeColor!.cgColor)
        context.setLineWidth(lineWidth)
        
        for polyline in overlay.polylines {
            
            let firstPoint = self.point(for: polyline.points()[0])
            context.move(to: firstPoint)
            
            for i in 1 ..< polyline.pointCount {
                let point = self.point(for: polyline.points()[i])
                context.addLine(to: point)
            }
            
            let point = self.point(for: polyline.points()[polyline.pointCount - 1])
            
            if firstPoint.equalTo(point) {
                context.closePath()
            } else {
                context.addLine(to: point)
            }
            
        }
        context.drawPath(using: .stroke)
        
        context.restoreGState()
    }
}

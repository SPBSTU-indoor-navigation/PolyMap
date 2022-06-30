//
//  MapLabel.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.06.2022.
//

import UIKit

class MapLabel: UILabel {
    
    var scale: CGFloat = 4
    
    var strokeSize: CGFloat = 1.5
    var strokeColor: UIColor = .black.withAlphaComponent(0.8)
    
    override func drawText(in rect: CGRect) {
        let font = self.font
        let textAlignment = self.textAlignment
        

        let bigSize: CGSize = .init(width: ceil(rect.width * scale), height: ceil(rect.height * scale))
        let bigRect: CGRect = .init(origin: rect.origin, size: bigSize)
        
        self.font = font?.withSize((font?.pointSize ?? 12) * scale)
        self.textAlignment = .center
        
        
        var img: CGImage? = nil
        
        UIGraphicsBeginImageContextWithOptions(bigSize, false, 0)
        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.translateBy(x: 0, y: bigSize.height)
            ctx.scaleBy(x: 1, y: -1)
            
            ctx.setLineWidth(self.strokeSize * scale)
            ctx.setLineJoin(CGLineJoin.round)
            ctx.setTextDrawingMode(CGTextDrawingMode.fillStroke)
            
            let textColor = self.textColor
            
            self.textColor = strokeColor
            super.drawText(in: bigRect)
            
            ctx.setTextDrawingMode(.fill)
            self.textColor = textColor
            super.drawText(in: bigRect)
            
            img = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        }
        UIGraphicsEndImageContext()
        
        
        self.font = font
        self.textAlignment = textAlignment
        
        guard let img = img else { return }

        let context = UIGraphicsGetCurrentContext()
        context?.interpolationQuality = .high
        context?.draw(img, in: rect)

    }
}

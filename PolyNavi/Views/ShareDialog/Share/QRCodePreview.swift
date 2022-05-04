//
//  QRCodePreview.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 02.05.2022.
//

import SwiftUI

struct QRCodePreview: View {
    @Binding var color: ShareDialog.ColorVariant
    @Binding var logo: ShareDialog.QRLogoVariant
    
    var body: some View {
        ZStack {
            Image(uiImage: Asset.Qr.qrBackground.image)
                .resizable()
                .interpolation(.high)
                .renderingMode(.template)
                .foregroundColor(.init(hex: color.preset.background))
            
            Image(uiImage: logo == .use ? Asset.Qr.qrData.image : Asset.Qr.qrDataFull.image)
                .resizable()
                .interpolation(.high)
                .renderingMode(.template)
                .foregroundColor(.init(hex: color.preset.primary))
            
            if logo == .use {
                Image(uiImage: Asset.Qr.qrLogo.image)
                    .resizable()
                    .interpolation(.high)
                    .renderingMode(.template)
                    .foregroundColor(.init(hex: color.preset.primary))
            }
        }.scaledToFit()
    }
}

struct QRCodePreview_Previews: PreviewProvider {
    static var previews: some View {
        QRCodePreview(color: .constant(.init(inverted: false, currentVariant: .orange)), logo: .constant(.none))
            .previewLayout(.fixed(width: 900, height: 600))
    }
}

//
//  AppClipCodePreview.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 21.04.2022.
//

import SwiftUI

struct AppClipCodePreview: View {
    @Binding var color: ShareDialog.ColorVariant
    @Binding var logoVariant: ShareDialog.LogoVariant
    @Binding var badgeVariant: ShareDialog.BadgeVariant
    
    var body: some View {
        ZStack {
            Image(uiImage: badgeVariant == .badge ? Asset.AppClip.Badge.badge.image : Asset.AppClip.Circle.appclipCBackground.image)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.init(hex: color.preset.background))
            
            if badgeVariant == .badge {
                Image(uiImage: Asset.AppClip.Badge.badgeText.image)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.init(hex: color.preset.badgeTextColor))
            }
            
            Image(uiImage: badgeVariant == .badge ? Asset.AppClip.Badge.appclipPrimary.image : Asset.AppClip.Circle.appclipCPrimary.image)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.init(hex: color.preset.primary))
            
            Image(uiImage: badgeVariant == .badge ? Asset.AppClip.Badge.appclipSecondary.image : Asset.AppClip.Circle.appclipCSecondary.image)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.init(hex: color.preset.secondary))
            
            if logoVariant == .phone {
                Image(uiImage: badgeVariant == .badge ? Asset.AppClip.Badge.appclipNfcPrimary.image : Asset.AppClip.Circle.appclipCNfcPrimary.image)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.init(hex: color.preset.primary))
                
                Image(uiImage: badgeVariant == .badge ? Asset.AppClip.Badge.appclipNfcSecondary.image : Asset.AppClip.Circle.appclipCNfcSecondary.image)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.init(hex: color.preset.secondary))
            } else {
                Image(uiImage: badgeVariant == .badge ? Asset.AppClip.Badge.appclipCamera.image : Asset.AppClip.Circle.appclipCCamera.image)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.init(hex: color.preset.primary))
            }
        }.scaledToFit()
    }
}

struct AppClipCodePreview_Previews: PreviewProvider {
    static var previews: some View {
        AppClipCodePreview(color: .init(get: { .greenWhite }, set: { _ in}), logoVariant: .init(get: { .phone }, set: { _ in}), badgeVariant: .init(get: { .circle }, set: { _ in}))
            .previewLayout(.fixed(width: 900, height: 600))
    }
}

//
//  SearchablePreview.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 23.04.2022.
//

import SwiftUI
import MapKit

struct SearchablePreview: View {
    var searchable: Searchable
    
    var body: some View {
        
        HStack {
            ZStack {
                if searchable is AttractionAnnotation {
                    Circle()
                        .foregroundColor(Color(Asset.Annotation.Colors.attractionBorder.color))
                    
                    Circle()
                        .foregroundColor(Color(Asset.Annotation.Colors.attractionBackground.color))
                        .padding(2.0)
                    
                    if let sprite = searchable.annotationSprite {
                        Image(uiImage: sprite)
                            .resizable(resizingMode: .stretch)
                            .interpolation(.high)
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .padding(2.0)
                    } else {
                        Text(searchable.additionalTitle ?? "")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .minimumScaleFactor(0.01)
                            .padding(.horizontal, 5)
                            .foregroundColor(Color(Asset.Annotation.Colors.attractionBorder.color))
                    }
                } else if searchable is AmenityAnnotation || searchable is EnviromentAmenityAnnotation {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color(searchable.backgroundSpriteColor))
                            .padding(3.0)
                        if let sprite = searchable.annotationSprite {
                            Image(uiImage: sprite)
                                .resizable(resizingMode: .stretch)
                                .interpolation(.high)
                                .aspectRatio(contentMode: .fit)
                                .padding(10.0)
                        }
                    }
                } else {
                    ZStack {
                        Circle()
                            .foregroundColor(Color(searchable.backgroundSpriteColor))
                        if let sprite = searchable.annotationSprite {
                            Image(uiImage: sprite)
                                .resizable(resizingMode: .stretch)
                                .interpolation(.high)
                                .aspectRatio(contentMode: .fit)
                                .padding(10.0)
                        }
                    }
                }
            }
            .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(searchable.mainTitle ?? "")
                    .lineLimit(1)
                
                if let place = searchable.place,
                   let floor = searchable.floor {
                    
                    Text("\(place) ??? \(floor)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        
    }
}

struct SearchablePreview_Previews: PreviewProvider {
    
    class Mock: Searchable {
        
        let t: MKAnnotation! = nil
        
        var annotation: MKAnnotation { t }
        
        var annotationSprite: UIImage? { nil }
        
        var backgroundSpriteColor: UIColor { .systemOrange }
        
        var mainTitle: String? { "???????????? ???????????? " }
        
        var additionalTitle: String? { "1" }
        
        var place: String? { "Place" }
        
        var floor: String? { "Floor" }
        
        var searchTags: [String] = []
    }
    
    
    static var previews: some View {
        SearchablePreview(searchable: Mock())
            .preferredColorScheme(.light)
            .previewLayout(PreviewLayout.sizeThatFits)
            .frame(width: 500, height: 100)
    }
}

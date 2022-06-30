//
//  CodeVariant.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 18.04.2022.
//

import SwiftUI

struct CodeVariant: View {
    @Binding var enabled: Bool
    @Binding var warning: Bool
    @State private var isPressed: Bool = false
    
    var title: String
    var image: Image
    
    var body: some View {
        VStack(alignment: .center, spacing: 8.0) {
            image
                .resizable(resizingMode: .stretch)
                .interpolation(.high)
                .antialiased(true)
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 90)
            Text(title)
            ZStack {
                

                if warning {
                    Image(systemName: "xmark.circle.fill")
                        .resizable(resizingMode: .stretch)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary)
                        .frame(width: 25.0, height: 25.0)
                } else {
                    Circle()
                        .stroke(Color.secondary, lineWidth: 2)
                        .background(Circle().fill(Color.clear))
                        .frame(width: 23, height: 23)
                }
                
                if !warning && enabled {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable(resizingMode: .stretch)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.accentColor)
                        .frame(width: 25.0, height: 25.0)
                    
                }
                
            }.frame(width: 25, height: 25)
        }
        .foregroundColor(isPressed ? .secondary : .primary)
    }
}

struct CodeVariant_Previews: PreviewProvider {
    static var previews: some View {
        CodeVariant(enabled: .constant(false), warning: .constant(true), title: "Title", image: Image(systemName: "qrcode"))
            .previewLayout(.fixed(width: 200, height: 200))
    }
}

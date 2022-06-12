//
//  HelloMessageLine.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 12.06.2022.
//

import SwiftUI

struct HelloMessageLine: View {
    @State var title: String
    @State var content: String
    @State var image: Image
    var body: some View {
        
        HStack() {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.accentColor)
                .frame(width: 40, height: 40)
                .padding(.trailing)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(content)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}

struct HelloMessageLine_Previews: PreviewProvider {
    static var previews: some View {
        HelloMessageLine(title: "Title", content: "Content", image: .init(systemName: "text.bubble"))
            .previewLayout(.sizeThatFits)
    }
}

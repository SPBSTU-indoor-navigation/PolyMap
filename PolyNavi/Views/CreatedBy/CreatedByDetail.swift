//
//  CreatedByDetail.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 26.09.2024.
//

import SwiftUI

struct CreatedByDetail: View {
    
    var title: String
    var description: String
    var authors: [String]
    
    var body: some View {
        NavigationView {
            VStack {
                Text(title)
                    .font(.largeTitle)
                    .bold()
                
                    .padding()
                
                Text(description)
                    .padding()
                
                List() {
                    ForEach(authors, id: \.self) { author in
                        Text(author)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    CreatedByDetail(title: "Title", description: "Descr", authors: [
        "Name1",
        "Name2"
    ])
}

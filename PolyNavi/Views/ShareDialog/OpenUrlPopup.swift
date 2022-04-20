//
//  OpenUrlPopup.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 19.04.2022.
//

import SwiftUI

struct OpenUrlPopup: View {
    @State var url: String = ""
    @State var data: CodeGeneratorModel.DataResponse? = nil
    
    var body: some View {
        List {
            Text(url)
            
            if let data = data {
                Text("from: \(data.from.uuidString)")
                Text("to: \(data.to.uuidString)")
                
                Section {
                    Text("text: \(data.helloText)")
                }
            }
        }.onAppear {
            let id = url.split(separator: "/").last! 
            
            CodeGeneratorProvider.loadData(id: String(id), completion: {
                data = $0.data
            })
            
        }
    }
}

struct OpenUrlPopup_Previews: PreviewProvider {
    static var previews: some View {
        OpenUrlPopup(url: "234")
    }
}

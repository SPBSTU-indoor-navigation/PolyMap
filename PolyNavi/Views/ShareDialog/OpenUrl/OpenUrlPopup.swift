//
//  OpenUrlPopup.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 19.04.2022.
//

import SwiftUI

struct OpenUrlPopup: View {
    @State var id: String = ""
    @State var data: ApiStatus<CodeGeneratorModel.DataResponse>? = nil
    
    var body: some View {
        ZStack {
            if let data = data {
                switch data {
                case .successWith(let data):
                    OpenUrlPopupContent(data: .constant(data))
                case .errorNoInternet:
                    Text("errorNoInternet")
                case .error:
                    Text("error")
                }
            } else {
                ActivityIndicator(style: .medium)
            }
        }
        .onAppear {
            CodeGeneratorProvider.loadData(id: id, completion: {
                self.data = $0
            })
        }
    }
}

struct OpenUrlPopup_Previews: PreviewProvider {
    static var previews: some View {
        OpenUrlPopup(id: "234")
    }
}

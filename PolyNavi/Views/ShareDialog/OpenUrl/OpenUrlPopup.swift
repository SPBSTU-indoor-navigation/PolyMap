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
                    VStack {
                        Image(systemName: "wifi.slash")
                        Text("errorNoInternet")
                    }
                case .error:
                    VStack {
                        Image(systemName: "wifi.slash")
                        Text("errorNoInternet")
                    }
                }
            } else {
                ActivityIndicator(style: .medium)
            }
        }
        .onAppear {
            CodeGeneratorProvider.loadData(id: id, completion: {
                self.data = $0
                
                if $0.data == nil {
                    self.dismiss(animated: true)
                }
            })
        }
    }
}

struct OpenUrlPopup_Previews: PreviewProvider {
    static var previews: some View {
        OpenUrlPopup(id: "234")
    }
}

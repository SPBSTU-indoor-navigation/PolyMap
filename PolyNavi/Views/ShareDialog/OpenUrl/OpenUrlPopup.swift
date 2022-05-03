//
//  OpenUrlPopup.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 19.04.2022.
//

import SwiftUI

struct OpenUrlPopup: View {
    @State var id: String = ""
    @State var data: CodeGeneratorModel.DataResponse? = nil
    
    var body: some View {
        ZStack {
            
            if let data = data {
                OpenUrlPopupContent(data: .init(get: { data }, set: { _ in}))
            } else {
                ActivityIndicator(style: .medium)
            }
        }
        .onAppear {
            CodeGeneratorProvider.loadData(id: id, completion: {
                if case .successWith(let data) = $0 {
                    self.data = data
                } else {
                    dismiss(animated: true)
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

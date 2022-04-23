//
//  OpenUrlPopupContent.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 23.04.2022.
//

import SwiftUI

struct OpenUrlPopupContent: View {
    @Binding var data: CodeGeneratorModel.DataResponse
    var body: some View {
        VStack {

            Text("Добро пожаловать")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40.0)
            
            VStack(alignment: .leading) {
                Text("С вами поделились маршрутом от вхожа до  ГЗ")
                    .padding()

                Text(data.helloText)
                    .padding(.top, 50.0)
                    .padding()
                
            }.frame(width: 500)
            
            
            Spacer()
            
            Text("Будет проложен маршрут в \"эксклюзивном\" режиме, для выхода из него, смахните шторку вверх и нажмите на кнопку \"завершить\"")
                .foregroundColor(.secondary)
                .font(.footnote)
                .padding(.horizontal, 20)
                
            
            Button(action: { }, label: {
                Text("Продолжить")
                    .font(.headline)
                    .frame(maxWidth: 300)
                    .frame(height: 46)
            })
                .foregroundColor(.white)
                .background(Color(Asset.accentColor.color))
                .cornerRadius(10)
        }.padding()
    }
}

struct OpenUrlPopupContent_Previews: PreviewProvider {
    static var previews: some View {
        OpenUrlPopupContent(data: .constant(.init(from: UUID(), to: UUID(), helloText: "hello world")))
            .previewLayout(PreviewLayout.sizeThatFits)
            .frame(width: 500, height: 900)
    }
}

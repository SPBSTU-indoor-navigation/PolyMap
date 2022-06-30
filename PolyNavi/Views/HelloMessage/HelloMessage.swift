//
//  HelloMessage.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 12.06.2022.
//

import SwiftUI

struct HelloMessage: View {
    
    static func open(to vc: UIViewController) {
        if Storage.value(key: "firstOpen") == nil {
            Storage.set(value: true, forKey: "firstOpen")
            HelloMessage().present(to: vc, animated: true)
        }
    }
    
    var body: some View {
        
        VStack(spacing: 20) {
            Text(L10n.HelloPopup.title)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .padding(.top, 40)
                .padding(.bottom, 30)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 30) {
                    HelloMessageLine(title: L10n.HelloPopup.Indoor.title, content: L10n.HelloPopup.Indoor.message, image: .init(systemName: "square.split.bottomrightquarter.fill"))
                    
                    HelloMessageLine(title: L10n.HelloPopup.Route.title, content: L10n.HelloPopup.Route.message, image: .init(systemName: "point.topleft.down.curvedto.point.bottomright.up.fill"))
                    
                    HelloMessageLine(title: L10n.HelloPopup.Share.title, content: L10n.HelloPopup.Share.message, image: .init(systemName: "qrcode"))
                }
                .padding()
            }
            Spacer()
            Button(action: {
                dismiss(animated: true)
            }, label: {
                Text(L10n.HelloPopup.continue)
                    .font(.headline)
                    .frame(maxWidth: 300)
                    .frame(height: 46)
            })
            .foregroundColor(.white)
            .background(Color(Asset.accentColor.color))
            .cornerRadius(10)
        }
        .frame(maxWidth: 500)
        .padding(.vertical)
        
    }
}

struct HelloMessage_Previews: PreviewProvider {
    static var previews: some View {
        HelloMessage()
            .previewDevice("iPad Pro (11-inch) (3rd generation)")
    }
}

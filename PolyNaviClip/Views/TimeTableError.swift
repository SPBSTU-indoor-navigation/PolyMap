//
//  TimeTableError.swift
//  PolyNaviClip
//
//  Created by Andrei Soprachev on 18.02.2022.
//

import SwiftUI
import StoreKit

struct TimeTableError: View {
    var body: some View {
        VStack {
            Text("Расписание недоступно в ознакомительной версии приложения")
            Button(action: openAppstore) {
                Text("Полная версия")
            }
        }

        
    }
    
    func openAppstore() {
        guard let scene = UIApplication.shared.connectedScenes.first else { return }
        
        let config = SKOverlay.AppClipConfiguration(position: .bottom)
        let overlay = SKOverlay(configuration: config)
        overlay.present(in: scene as! UIWindowScene)
    }
}

struct TimeTableError_Previews: PreviewProvider {
    static var previews: some View {
        TimeTableError()
    }
}

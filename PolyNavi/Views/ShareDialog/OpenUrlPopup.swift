//
//  OpenUrlPopup.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 19.04.2022.
//

import SwiftUI

struct OpenUrlPopup: View {
    @State var url: String = ""
    var body: some View {
        Text(url)
    }
}

struct OpenUrlPopup_Previews: PreviewProvider {
    static var previews: some View {
        OpenUrlPopup(url: "234")
    }
}

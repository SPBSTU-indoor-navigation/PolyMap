//
//  ShareDialog.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.04.2022.
//

import SwiftUI
import Alamofire
import MapKit

struct ShareDialog: View {    
    struct ColorVariant {
        struct Preset {
            let background: String
            let primary: String
            let secondary: String
            let badgeTextColor: String
        }
        
        struct ColorPreset {
            let normal, inverted: Preset
        }
        
        enum Variant: String, CaseIterable, Identifiable {
            case black,
                 gray,
                 red,
                 orange,
                 green,
                 teal,
                 blue,
                 indigo,
                 purple
            
            
            var id: Self { self }
            
            var localizrdName: String {
                let names: [Self: String] = [
                    .black:  L10n.Share.ColorVariant.Preset.black,
                    .gray:   L10n.Share.ColorVariant.Preset.gray,
                    .red:    L10n.Share.ColorVariant.Preset.red,
                    .orange: L10n.Share.ColorVariant.Preset.orange,
                    .green:  L10n.Share.ColorVariant.Preset.green,
                    .teal:   L10n.Share.ColorVariant.Preset.teal,
                    .blue:   L10n.Share.ColorVariant.Preset.blue,
                    .indigo: L10n.Share.ColorVariant.Preset.indigo,
                    .purple: L10n.Share.ColorVariant.Preset.purple,
                ]
                
                if let name = names[self] {
                    return name
                } else {
                    return "-"
                }
            }
            
            var preset: ColorPreset {
                let presets: [Self: ColorPreset] = [
                    .black: .init(normal:    .init(background: "000", primary: "fff", secondary: "888", badgeTextColor: "fff"),
                                  inverted:  .init(background: "fff", primary: "000", secondary: "888", badgeTextColor: "000")),
                    
                        .gray: .init(normal:  .init(background: "777", primary: "fff", secondary: "aaa", badgeTextColor: "fff"),
                                     inverted:   .init(background: "fff", primary: "777", secondary: "aaa", badgeTextColor: "000")),
                    
                        .red: .init(normal:      .init(background: "ff3b30", primary: "fff", secondary: "f99", badgeTextColor: "fff"),
                                    inverted:    .init(background: "fff", primary: "ff3b30", secondary: "f99", badgeTextColor: "000")),
                    
                        .orange: .init(normal:   .init(background: "EE7733", primary: "fff", secondary: "eb8", badgeTextColor: "fff"),
                                       inverted: .init(background: "fff", primary: "EE7733", secondary: "eb8", badgeTextColor: "000")),
                    
                        .green: .init(normal:   .init(background: "33AA22", primary: "fff", secondary: "9d9", badgeTextColor: "fff"),
                                      inverted: .init(background: "fff", primary: "33AA22", secondary: "9d9", badgeTextColor: "000")),
                    
                        .teal: .init(normal:    .init(background: "00A6A1", primary: "fff", secondary: "8dc", badgeTextColor: "fff"),
                                     inverted:  .init(background: "fff", primary: "00A6A1", secondary: "8dc", badgeTextColor: "000")),
                    
                        .blue: .init(normal:    .init(background: "007AFF", primary: "fff", secondary: "7df", badgeTextColor: "fff"),
                                     inverted:  .init(background: "fff", primary: "007AFF", secondary: "7df", badgeTextColor: "000")),
                    
                        .indigo: .init(normal:  .init(background: "5856D6", primary: "fff", secondary: "bbe", badgeTextColor: "fff"),
                                       inverted:.init(background: "fff", primary: "5856D6", secondary: "bbe", badgeTextColor: "000")),
                    
                        .purple: .init(normal:  .init(background: "CC73E1", primary: "fff", secondary: "ebe", badgeTextColor: "fff"),
                                       inverted:.init(background: "fff", primary: "CC73E1", secondary: "ebe", badgeTextColor: "000"))
                ]
                
                if let preset = presets[self] {
                    return preset
                } else {
                    return presets[.black]!
                }
            }
        }
        
        
        var inverted: Bool
        var currentVariant: Variant
        
        var preset: Preset {
            let t = currentVariant.preset
            return inverted ? t.inverted : t.normal
        }
    }
    
    enum LogoVariant: String, CaseIterable, Identifiable {
        case camera, phone
        
        var id: Self { self }
        
        var localizrdName: String {
            switch self {
            case .camera:
                return L10n.Share.LogoVariant.camera
            case .phone:
                return L10n.Share.LogoVariant.phone
            }
        }
    }
    
    enum QRLogoVariant: String, CaseIterable, Identifiable {
        case use, none
        
        var id: Self { self }
        
        var localizrdName: String {
            switch self {
            case .use:
                return "Использовать"
            case .none:
                return "Не использовать"
            }
        }
    }
    
    enum BadgeVariant: String, CaseIterable, Identifiable {
        case badge, circle
        
        var id: Self { self }
        
        var localizrdName: String {
            switch self {
            case .circle:
                return L10n.Share.BadgeVariant.circle
            case .badge:
                return L10n.Share.BadgeVariant.badge
            }
        }
    }
    
    struct Settings {
        let color: ColorVariant?
        let logo: LogoVariant?
        let bage: BadgeVariant?
        let qrLogoVariant: QRLogoVariant?
        
        let isQR: Bool
        let from: UUID
        let to: UUID
        let text: String?
        
        let asphalt: Bool
        let serviceRoute: Bool
        let allowParameterChange: Bool
        
        var routeSettings: CodeGeneratorProvider.RouteSettings {
            .init(isQR: isQR, from: from, to: to, text: text, asphalt: asphalt, serviceRoute: serviceRoute, allowParameterChange: allowParameterChange)
        }
    }
    
    @State var isQR: Bool = false
    @State var showHelloText: Bool = false
    @State var routeParameterChanging: Bool = false
    @State var helloText: String = ""
    @State var colorVariant: ColorVariant = .init(inverted: false, currentVariant: .green)
    @State var logoVariant: LogoVariant = .camera
    @State var badgeVariant: BadgeVariant = .badge
    @State var qrLogoVariant: QRLogoVariant = .use
    
    @State var serverStatus: ApiStatus<CodeGeneratorModel.ServerStatus>? = nil
    @State var serverStatusAlert: Bool = false
    
    var from: Searchable & BaseAnnotation
    var to: Searchable & BaseAnnotation
    var asphalt: Bool
    var serviceRoute: Bool
    
    var body: some View {
        NavigationView {
            List {
                Text(L10n.Share.mainInfo)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .listRowBackground(Color.clear)
                
                Section {
                    HStack {
                        Text(L10n.MapInfo.Route.Info.from)
                        SearchablePreview(searchable: from)
                            .padding(.vertical, 5)
                    }
                    
                    HStack {
                        Text(L10n.MapInfo.Route.Info.to)
                        SearchablePreview(searchable: to)
                            .padding(.vertical, 5)
                    }
                }
                
                Section(content: {
                    Toggle(isOn: $routeParameterChanging, label: { Text("Изменение параметров") })
                }, footer: {
                    Text("Разрешить пользователю менять параметры построеня маршрута (служебные маршруты/асфальтированные дороги)")
                })
                
                
                HelloTextSection(showHelloText: $showHelloText, helloText: $helloText)
                CodeVariantSection(isQR: $isQR)
                
                if !isQR {
                    SettingsLine(title: L10n.Share.ColorVariant.title, current: .constant(colorVariant.currentVariant.localizrdName)) {
                        ColorSection(colorVariant: $colorVariant, logoVariant: $logoVariant, badgeVariant: $badgeVariant)
                    }
                    
                    SettingsLine(title: L10n.Share.LogoVariant.title, current: .constant(logoVariant.localizrdName)) {
                        LogoSection(colorVariant: $colorVariant, logoVariant: $logoVariant, badgeVariant: $badgeVariant)
                    }
                    
                    SettingsLine(title: L10n.Share.BadgeVariant.title, current: .constant(badgeVariant.localizrdName)) {
                        BadgeSection(colorVariant: $colorVariant, logoVariant: $logoVariant, badgeVariant: $badgeVariant)
                    }
                    
                } else {
                    SettingsLine(title: L10n.Share.ColorVariant.title, current: .constant(colorVariant.currentVariant.localizrdName)) {
                        QRColorSection(colorVariant: $colorVariant, logoVariant: $qrLogoVariant)
                    }
                    
                    SettingsLine(title: "Лого", current: .constant(qrLogoVariant.localizrdName)) {
                        QRLogoSection(colorVariant: $colorVariant, logoVariant: $qrLogoVariant)
                    }
                }
                
                Section {
                    CreateButton(serverReady: .constant(serverStatus?.data?.appclip == true),
                                 settings: Settings(color: colorVariant, logo: logoVariant, bage: badgeVariant, qrLogoVariant: qrLogoVariant, isQR: isQR, from: from.imdfID, to: to.imdfID, text: helloText, asphalt: asphalt, serviceRoute: serviceRoute, allowParameterChange: routeParameterChanging))
                }
            }
            .navigationBarTitle("\(L10n.Share.navigationTitle)", displayMode: .inline)
        }
        .navigationViewStyle(.stack)
        .onAppear(perform: {
            serverStatus = nil
            CodeGeneratorProvider.loadStatus(completion: { res in
                serverStatus = res
                serverStatusAlert = res.data?.appclip != true
            })
            
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = Asset.accentColor.color
        })
        .alert(isPresented: $serverStatusAlert) {
            Alert(
                title: Text(L10n.Share.ErrorAlert.title),
                message: Text(L10n.Share.ErrorAlert.message)
            )
        }
        
    }
    
    
    struct CreateButton: View {
        @Binding var serverReady: Bool
        var settings: Settings
        
        var body: some View {
            HStack {
                Spacer()
                ZStack {
                    if serverReady {
                        NavigationLink(destination: { ShareResult(settings: settings) }, label: { EmptyView() })
                            .opacity(0.0)
                    }
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 200)
                        .foregroundColor(serverReady ? .accentColor : .secondary)
                    Text(L10n.Share.create)
                        .padding(.vertical, 9.0)
                        .font(.headline)
                        .frame(minHeight: 46)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Spacer()
            }.listRowBackground(Color.clear)
        }
    }
    
    struct CodeVariantSection: View {
        @Binding var isQR: Bool
        
        var body: some View {
            Section(content: {
                HStack {
                    Spacer()
                    
                    CodeVariant(enabled: $isQR, title: L10n.Share.CodeVariant.qr, image: Image(systemName: "qrcode"))
                        .simultaneousGesture(TapGesture().onEnded({
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isQR = true
                            }
                        }))
                    
                    Spacer()
                    Spacer()
                    
                    CodeVariant(enabled: .constant(!isQR), title: L10n.Share.CodeVariant.appClip, image: Image(uiImage: Asset.AppClip.appclipPreview.image))
                        .simultaneousGesture(TapGesture().onEnded({
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isQR = false
                            }
                        }))
                    Spacer()
                }.padding()
            }, header: {
                Text(L10n.Share.CodeVariant.title)
            }, footer: {
                Text(L10n.Share.CodeVariant.info)
            })
        }
    }
    
    struct HelloTextSection: View {
        @Binding var showHelloText: Bool
        @Binding var helloText: String
        
        var body: some View {
            Section(content: {
                Toggle(isOn: $showHelloText, label: { Text(L10n.Share.HelloText.title) })
                
                if showHelloText {
                    ZStack {
                        if helloText.isEmpty {
                            VStack{
                                HStack{
                                    Text(L10n.Share.HelloText.placehodler)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                        
                        TextView(text: $helloText) {
                            $0.backgroundColor = .clear
                            $0.clipsToBounds = false
                            $0.textContainerInset = .zero
                            $0.textContainer.lineFragmentPadding = 0
                            $0.font = .preferredFont(forTextStyle: .body)
                        }
                        .frame(height: 200)
                    }
                }
            }, footer: {
                Text(L10n.Share.HelloText.info)
            })
        }
    }
    
    struct SettingsLine<Content: View>: View {
        @Binding var current: String

        let title: String
        let content: Content
                        
        init(title: String, current: Binding<String>, @ViewBuilder content: () -> Content) {
            self.content = content()
            self.title = title
            self._current = current
        }
        
        var body: some View {
            NavigationLink(destination: content, label: {
                HStack {
                    Text(title)
                    Spacer()
                    Text(current).foregroundColor(.secondary)
                }
            })
        }
    }
    
    struct ColorSection: View {
        @Binding var colorVariant: ShareDialog.ColorVariant
        @Binding var logoVariant: ShareDialog.LogoVariant
        @Binding var badgeVariant: ShareDialog.BadgeVariant
        
        var body: some View {
            VStack(spacing: 0) {
                List {
                    ForEach(ShareDialog.ColorVariant.Variant.allCases) { variant in
                        Button(action: {
                            withAnimation {
                                colorVariant.currentVariant = variant
                            }
                        }, label: {
                            HStack {
                                Circle()
                                    .strokeBorder(Color.init(hex: colorVariant.inverted ? variant.preset.inverted.background : variant.preset.normal.background), lineWidth: 5)
                                    .background(Circle()
                                                    .foregroundColor(.init(hex: colorVariant.inverted ? variant.preset.inverted.primary : variant.preset.normal.primary))
                                    )
                                    .frame(width: 20, height: 20)
                                    
                                Text(variant.localizrdName).foregroundColor(.primary)
                                Spacer()
                                if colorVariant.currentVariant == variant {
                                    Image(systemName: "checkmark").foregroundColor(.accentColor)
                                }
                            }
                        })
                    }
                }
                ZStack {
                    ZStack {}
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemGroupedBackground))
                    .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        AppClipCodePreview(color: $colorVariant, logoVariant: $logoVariant, badgeVariant: $badgeVariant)
                            .frame(maxWidth: 250)
                        Button(action: {
                            withAnimation {
                                colorVariant.inverted.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.up.arrow.down")
                                Text("Поменять цвета")
                            }
                        }
                    }.padding()
                }
            }
        }
    }
    
    struct QRColorSection: View {
        @Binding var colorVariant: ShareDialog.ColorVariant
        @Binding var logoVariant: ShareDialog.QRLogoVariant
        
        var body: some View {
            VStack(spacing: 0) {
                List {
                    ForEach(ShareDialog.ColorVariant.Variant.allCases) { variant in
                        Button(action: {
                            withAnimation {
                                colorVariant.currentVariant = variant
                            }
                        }, label: {
                            HStack {
                                Circle()
                                    .strokeBorder(Color.init(hex: colorVariant.inverted ? variant.preset.inverted.background : variant.preset.normal.background), lineWidth: 5)
                                    .background(Circle()
                                                    .foregroundColor(.init(hex: colorVariant.inverted ? variant.preset.inverted.primary : variant.preset.normal.primary))
                                    )
                                    .frame(width: 20, height: 20)
                                
                                Text(variant.localizrdName).foregroundColor(.primary)
                                Spacer()
                                if colorVariant.currentVariant == variant {
                                    Image(systemName: "checkmark").foregroundColor(.accentColor)
                                }
                            }
                        })
                    }
                }
                ZStack {
                    ZStack {}
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemGroupedBackground))
                    .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        QRCodePreview(color: $colorVariant, logo: $logoVariant)
                            .frame(maxWidth: 250)
                        Button(action: {
                            withAnimation {
                                colorVariant.inverted.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.up.arrow.down")
                                Text("Поменять цвета")
                            }
                        }
                    }.padding()
                }
            }
        }
    }
                           
    
    struct LogoSection: View {
        @Binding var colorVariant: ShareDialog.ColorVariant
        @Binding var logoVariant: ShareDialog.LogoVariant
        @Binding var badgeVariant: ShareDialog.BadgeVariant
        
        var body: some View {
            VStack(spacing: 0) {
                List {
                    Section(footer: Text(L10n.Share.LogoVariant.info)) {
                        ForEach(ShareDialog.LogoVariant.allCases) { variant in
                            Button(action: {
                                logoVariant = variant
                            }, label: {
                                HStack {
                                    Text(variant.localizrdName).foregroundColor(.primary)
                                    Spacer()
                                    if logoVariant == variant {
                                        Image(systemName: "checkmark").foregroundColor(.accentColor)
                                    }
                                }
                            })
                        }
                    }
                }
                
                ZStack {
                    ZStack {}
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemGroupedBackground))
                    .edgesIgnoringSafeArea(.all)
                    
                    AppClipCodePreview(color: $colorVariant, logoVariant: $logoVariant, badgeVariant: $badgeVariant)
                        .frame(maxWidth: 250)
                }
            }
            
        }
    }
    
    struct BadgeSection: View {
        @Binding var colorVariant: ShareDialog.ColorVariant
        @Binding var logoVariant: ShareDialog.LogoVariant
        @Binding var badgeVariant: ShareDialog.BadgeVariant
        
        var body: some View {
            VStack(spacing: 0) {
                List {
                    Section(footer: Text(L10n.Share.BadgeVariant.info)) {
                        ForEach(ShareDialog.BadgeVariant.allCases) { variant in
                            Button(action: {
                                badgeVariant = variant
                            }, label: {
                                HStack {
                                    Text(variant.localizrdName).foregroundColor(.primary)
                                    Spacer()
                                    if badgeVariant == variant {
                                        Image(systemName: "checkmark").foregroundColor(.accentColor)
                                    }
                                }
                            })
                        }
                    }
                }
                
                ZStack {
                    ZStack {}
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemGroupedBackground))
                    .edgesIgnoringSafeArea(.all)
                    
                    AppClipCodePreview(color: $colorVariant, logoVariant: $logoVariant, badgeVariant: $badgeVariant)
                        .frame(maxWidth: 250)
                }
            }
        }
    }
    
    struct QRLogoSection: View {
        @Binding var colorVariant: ShareDialog.ColorVariant
        @Binding var logoVariant: ShareDialog.QRLogoVariant
        
        var body: some View {
            VStack(spacing: 0) {
                List {
                    Section {
                        ForEach(ShareDialog.QRLogoVariant.allCases) { variant in
                            Button(action: {
                                logoVariant = variant
                            }, label: {
                                HStack {
                                    Text(variant.localizrdName).foregroundColor(.primary)
                                    Spacer()
                                    if logoVariant == variant {
                                        Image(systemName: "checkmark").foregroundColor(.accentColor)
                                    }
                                }
                            })
                        }
                    }
                }
                
                ZStack {
                    ZStack {}
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemGroupedBackground))
                    .edgesIgnoringSafeArea(.all)
                    
                    QRCodePreview(color: $colorVariant, logo: $logoVariant)
                        .frame(maxWidth: 250)
                }
            }
        }
    }
}

struct ShareDialog_Previews: PreviewProvider {
    static var previews: some View {
        
        ShareDialog(from: EnviromentAmenityAnnotation(coordinate: .init(latitude: 0, longitude: 0), imdfID: UUID(), properties: .init(name: nil, alt_name: nil, category: .banch, detailLevel: 1), detailLevel: 1),
                    to: EnviromentAmenityAnnotation(coordinate: .init(latitude: 0, longitude: 0), imdfID: UUID(), properties: .init(name: nil, alt_name: nil, category: .banch, detailLevel: 1), detailLevel: 1),
                    asphalt: false,
                    serviceRoute: false)
            .preferredColorScheme(.dark)
        
        ShareDialog.ColorSection(colorVariant: .constant(.init(inverted: true, currentVariant: .green)), logoVariant: .constant(.camera), badgeVariant: .constant(.badge))
    }
}

//
//  ShareDialog.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.04.2022.
//

import SwiftUI
import Alamofire

struct ShareDialog: View {    
    enum ColorVariant: String, CaseIterable, Identifiable {
        
        struct Preset {
            let background: String
            let primary: String
            let secondary: String
            let badgeTextColor: String
        }
        
        case whiteD, blackL, greenL, greenD
        
        var id: Self { self }
        
        var localizrdName: String {
            switch self {
            case .whiteD:
                return "белый на черном"
            case .blackL:
                return "черные на белом"
            case .greenL:
                return "зелёный на белом"
            case .greenD:
                return "зелёный на черном"
            }
        }
        
        var preset: Preset {
            switch self {
            case .whiteD:
                return Preset(background: "000", primary: "fff", secondary: "888", badgeTextColor: "fff")
            case .blackL:
                return Preset(background: "fff", primary: "000", secondary: "888", badgeTextColor: "000")
            case .greenL:
                return Preset(background: "fff", primary: "33aa22", secondary: "a8db9f", badgeTextColor: "000")
            case .greenD:
                return Preset(background: "33aa22", primary: "fff", secondary: "a8db9f", badgeTextColor: "fff")
            }
        }
    }
    
    enum LogoVariant: String, CaseIterable, Identifiable {
        case camera, phone
        
        var id: Self { self }
        
        var localizrdName: String {
            switch self {
            case .camera:
                return "Сканировать"
            case .phone:
                return "NFC"
            }
        }
    }
    
    enum BadgeVariant: String, CaseIterable, Identifiable {
        case circle, badge
        
        var id: Self { self }
        
        var localizrdName: String {
            switch self {
            case .circle:
                return "Только код"
            case .badge:
                return "Код в прямоугольнике с фоном"
            }
        }
    }
    
    struct Settings {
        let color: ColorVariant?
        let logo: LogoVariant?
        let bage: BadgeVariant?
        
        let isQR: Bool
        let from: UUID
        let to: UUID
        let text: String?
    }
    
    @State var isQR: Bool = false
    @State var showHelloText: Bool = false
    @State var helloText: String = ""
    @State var colorVariant: ColorVariant = .whiteD
    @State var logoVariant: LogoVariant = .camera
    @State var badgeVariant: BadgeVariant = .circle
    
    @State var serverStatus: ApiStatus<CodeGeneratorModel.ServerStatus>? = nil
    @State var serverStatusAlert: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Text("Вы можете создать QR код ассоциированный с этим маршрутом")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .listRowBackground(Color.clear)
                
                HelloTextSection(showHelloText: $showHelloText, helloText: $helloText)
                CodeVariantSection(isQR: $isQR)
                
                if !isQR {
                    ColorSection(colorVariant: $colorVariant)
                    LogoSection(logoVariant: $logoVariant)
                    BadgeSection(badgeVariant: $badgeVariant)
                }
                
                Section {
                    CreateButton(isQR: $isQR, serverReady: (serverStatus?.data?.appclip == true).bindig, helloText: $helloText, colorVariant: $colorVariant, logoVariant: $logoVariant, badgeVariant: $badgeVariant)
                }
            }
            .navigationBarTitle("Создание кода", displayMode: .inline)
        }
        .navigationViewStyle(.stack)
        .onAppear(perform: {
            serverStatus = nil
            CodeGeneratorProvider.loadStatus(completion: { res in
                serverStatus = res
                serverStatusAlert = res.data?.appclip != true
            })
        })
        .alert(isPresented: $serverStatusAlert) {
            Alert(
                title: Text( "Сервер недоступен"),
                message: Text("Сервер генерации кодов временно недоступен, попробуйте позже или обратитесь напрямую к разработчику")
            )
        }
        
    }
    
    
    struct CreateButton: View {
        @Binding var isQR: Bool
        @Binding var serverReady: Bool
        @Binding var helloText: String
        @Binding var colorVariant: ColorVariant
        @Binding var logoVariant: LogoVariant
        @Binding var badgeVariant: BadgeVariant
        
        var body: some View {
            HStack {
                Spacer()
                ZStack {
                    if serverReady {
                        NavigationLink(destination: { ShareResult(settings: Settings(color: colorVariant, logo: logoVariant, bage: badgeVariant, isQR: isQR, from: UUID(), to: UUID(), text: helloText)) }, label: { EmptyView() })
                            .opacity(0.0)
                    }
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 200)
                        .foregroundColor(serverReady ? .accentColor : .secondary)
                    Text("Создать")
                        .padding(.vertical, 9.0)
                        .font(.headline)
                        .foregroundColor(.primary)
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
                    
                    CodeVariant(enabled: $isQR, title: "QR", image: Image(systemName: "qrcode"))
                        .simultaneousGesture(TapGesture().onEnded({
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isQR = true
                            }
                        }))
                    
                    Spacer()
                    Spacer()
                    
                    CodeVariant(enabled: (!isQR).bindig, title: "AppClip", image: Image(systemName: "appclip"))
                        .simultaneousGesture(TapGesture().onEnded({
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isQR = false
                            }
                        }))
                    Spacer()
                }.padding()
            }, header: {
                Text("Тип кода")
            }, footer: {
                Text("QR код может содержать в себе маршру от любой одной точки до любой другой\n\nAppClip код может содержать маршрут начинающийся только у главного входа в кампус, однако выглядит красивее")
            })
        }
    }
    
    struct HelloTextSection: View {
        @Binding var showHelloText: Bool
        @Binding var helloText: String
        
        var body: some View {
            Section(content: {
                Toggle(isOn: $showHelloText, label: { Text("Отображать приветствие") })
                if showHelloText {
                    ZStack {
                        if helloText.isEmpty {
                            VStack{
                                HStack{
                                    Text("Введите приветсвенное сообщение")
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
                Text("Будет показываться во всплывающем окне после сканирования кода")
            })
        }
    }
    
    struct ColorSection: View {
        @Binding var colorVariant: ShareDialog.ColorVariant
        
        var body: some View {
            
            NavigationLink(destination: {
                List {
                    ForEach(ShareDialog.ColorVariant.allCases) { variant in
                        Button(action: {
                            
                            colorVariant = variant
                        }, label: {
                            HStack {
                                Text(variant.localizrdName).foregroundColor(.primary)
                                Spacer()
                                if colorVariant == variant {
                                    Image(systemName: "checkmark").foregroundColor(.accentColor)
                                }
                            }
                        })
                    }
                }
            }, label: {
                HStack {
                    Text("Цветовая палитра")
                    Spacer()
                    Text(colorVariant.localizrdName).foregroundColor(.secondary)
                }
            })
        }
    }
    
    struct LogoSection: View {
        @Binding var logoVariant: ShareDialog.LogoVariant
        
        var body: some View {
            
            NavigationLink(destination: {
                List {
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
            }, label: {
                HStack {
                    Text("Иконка")
                    Spacer()
                    Text(logoVariant.localizrdName).foregroundColor(.secondary)
                }
            })
        }
    }
    
    struct BadgeSection: View {
        @Binding var badgeVariant: ShareDialog.BadgeVariant
        
        var body: some View {
            
            NavigationLink(destination: {
                List {
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
            }, label: {
                HStack {
                    Text("Форма")
                    Spacer()
                    Text(badgeVariant.localizrdName).foregroundColor(.secondary)
                }
            })
        }
    }
}

struct ShareDialog_Previews: PreviewProvider {
    static var previews: some View {
        ShareDialog()
            .environment(\.colorScheme, .dark)
    }
}

extension Bool {
    var bindig: Binding<Bool> { return Binding<Bool> ( get: { return self }, set: { _ in})}
}

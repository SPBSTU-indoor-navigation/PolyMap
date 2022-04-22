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
        
        case whiteBlack, blackWhite,
             grayWhite, whiteGray,
             redWhite, whiteRed,
             orangeWhite, whiteOrange,
             greenWhite, whiteGreen,
             tealWhite, whiteTeal,
             blueWhite, whiteBlue,
             indigoWhite, whiteIndigo,
             purpleWhite, whitePurple
        
        var id: Self { self }
        
        var localizrdName: String {
            
            let names: [Self: String] = [
                .whiteBlack: "Белый / Черный",
                .blackWhite: "Черный / Белый",
                .grayWhite: "Серый / Белый",
                .whiteGray: "Белый / Серый",
                .redWhite: "Красный / Белый",
                .whiteRed: "Белый / Красный",
                .orangeWhite: "Оранжевый / Белый",
                .whiteOrange: "Белый / Оранжевый",
                .greenWhite: "Зеленый / Белый",
                .whiteGreen: "Белый / Зеленый",
                .tealWhite: "Сине-зеленый / Белый",
                .whiteTeal: "Белый / Сине-зеленый",
                .blueWhite: "Синий / Белый",
                .whiteBlue: "Белый / Синий",
                .indigoWhite: "Индиго / Белый",
                .whiteIndigo: "Белый / Индиго",
                .purpleWhite: "Фиолетовый / Белый",
                .whitePurple: "Белый / Фиолетовый"
            ]
            
            if let name = names[self] {
                return name
            } else {
                return "-"
            }
        }
        
        var preset: Preset {
            let presets: [Self: Preset] = [
                .blackWhite: .init(background: "000", primary: "fff", secondary: "888", badgeTextColor: "fff"),
                .whiteBlack: .init(background: "fff", primary: "000", secondary: "888", badgeTextColor: "000"),
                
                .grayWhite:  .init(background: "777", primary: "fff", secondary: "aaa", badgeTextColor: "fff"),
                .whiteGray:  .init(background: "fff", primary: "777", secondary: "aaa", badgeTextColor: "000"),
                
                .redWhite:   .init(background: "ff3b30", primary: "fff", secondary: "f99", badgeTextColor: "fff"),
                .whiteRed:   .init(background: "fff", primary: "ff3b30", secondary: "f99", badgeTextColor: "000"),
                
                .orangeWhite:.init(background: "EE7733", primary: "fff", secondary: "eb8", badgeTextColor: "000"),
                .whiteOrange:.init(background: "fff", primary: "EE7733", secondary: "eb8", badgeTextColor: "000"),
                
                .greenWhite: .init(background: "33AA22", primary: "fff", secondary: "9d9", badgeTextColor: "fff"),
                .whiteGreen: .init(background: "fff", primary: "33AA22", secondary: "9d9", badgeTextColor: "000"),
                
                .tealWhite:  .init(background: "00A6A1", primary: "fff", secondary: "8dc", badgeTextColor: "fff"),
                .whiteTeal:  .init(background: "fff", primary: "00A6A1", secondary: "8dc", badgeTextColor: "000"),
                
                .blueWhite:  .init(background: "007AFF", primary: "fff", secondary: "7df", badgeTextColor: "fff"),
                .whiteBlue:  .init(background: "fff", primary: "007AFF", secondary: "7df", badgeTextColor: "000"),
                
                .indigoWhite:.init(background: "5856D6", primary: "fff", secondary: "bbe", badgeTextColor: "fff"),
                .whiteIndigo:.init(background: "fff", primary: "5856D6", secondary: "bbe", badgeTextColor: "000"),
                
                .purpleWhite:.init(background: "CC73E1", primary: "fff", secondary: "ebe", badgeTextColor: "fff"),
                .whitePurple:.init(background: "fff", primary: "CC73E1", secondary: "ebe", badgeTextColor: "000")
            ]
            
            if let preset = presets[self] {
                return preset
            } else {
                return .init(background: "fff", primary: "000", secondary: "888", badgeTextColor: "000")
            }
        }
    }
    
    enum LogoVariant: String, CaseIterable, Identifiable {
        case camera, phone
        
        var id: Self { self }
        
        var localizrdName: String {
            switch self {
            case .camera:
                return "Только сканирование"
            case .phone:
                return "NFC"
            }
        }
    }
    
    enum BadgeVariant: String, CaseIterable, Identifiable {
        case badge, circle
        
        var id: Self { self }
        
        var localizrdName: String {
            switch self {
            case .circle:
                return "Без логотипа"
            case .badge:
                return "Использовать логотип"
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
    @State var colorVariant: ColorVariant = .greenWhite
    @State var logoVariant: LogoVariant = .camera
    @State var badgeVariant: BadgeVariant = .badge
    
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
                    ColorSection(colorVariant: $colorVariant, logoVariant: $logoVariant, badgeVariant: $badgeVariant)
                    LogoSection(colorVariant: $colorVariant, logoVariant: $logoVariant, badgeVariant: $badgeVariant)
                    BadgeSection(colorVariant: $colorVariant, logoVariant: $logoVariant, badgeVariant: $badgeVariant)
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
                        .frame(minHeight: 46)
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
        @Binding var logoVariant: ShareDialog.LogoVariant
        @Binding var badgeVariant: ShareDialog.BadgeVariant
        
        var body: some View {
            
            NavigationLink(destination: {
                VStack {
                    List {
                        ForEach(ShareDialog.ColorVariant.allCases) { variant in
                            Button(action: {
                                
                                colorVariant = variant
                            }, label: {
                                HStack {
                                    Circle()
                                        .strokeBorder(Color.init(hex: variant.preset.background), lineWidth: 5)
                                        .background(Circle().foregroundColor(.init(hex: variant.preset.primary)))
                                        .frame(width: 20, height: 20)
                                    Text(variant.localizrdName).foregroundColor(.primary)
                                    Spacer()
                                    if colorVariant == variant {
                                        Image(systemName: "checkmark").foregroundColor(.accentColor)
                                    }
                                }
                            })
                        }
                    }
                    AppClipCodePreview(color: $colorVariant, logoVariant: $logoVariant, badgeVariant: $badgeVariant)
                        .frame(maxWidth: 250)
                        .padding()
                }
            }, label: {
                HStack {
                    Text("Цвет")
                    Spacer()
                    Text(colorVariant.localizrdName).foregroundColor(.secondary)
                }
            })
        }
    }
    
    struct LogoSection: View {
        @Binding var colorVariant: ShareDialog.ColorVariant
        @Binding var logoVariant: ShareDialog.LogoVariant
        @Binding var badgeVariant: ShareDialog.BadgeVariant
        
        var body: some View {
            
            NavigationLink(destination: {
                VStack {
                    List {
                        Section(footer: Text("Если вы объединяете код с NFC-меткой, выберите дизайн NFC. Если вы не вставляете NFC-метку, выберите дизайн «Только сканирование»")) {
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
                    AppClipCodePreview(color: $colorVariant, logoVariant: $logoVariant, badgeVariant: $badgeVariant)
                        .frame(maxWidth: 250)
                        .padding()
                }

            }, label: {
                HStack {
                    Text("Тип кода")
                    Spacer()
                    Text(logoVariant.localizrdName).foregroundColor(.secondary)
                }
            })
        }
    }
    
    struct BadgeSection: View {
        @Binding var colorVariant: ShareDialog.ColorVariant
        @Binding var logoVariant: ShareDialog.LogoVariant
        @Binding var badgeVariant: ShareDialog.BadgeVariant
        
        var body: some View {
            NavigationLink(destination: {
                VStack {
                    List {
                        Section(footer: Text("Рекомендуется использовать код с логотипом, за сключением случаев, когда невозможно удовлетворить требования к свободному пространству или если код будет размещаться на одноразовых товарах")) {
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
                    
                    AppClipCodePreview(color: $colorVariant, logoVariant: $logoVariant, badgeVariant: $badgeVariant)
                        .frame(maxWidth: 250)
                        .padding()
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

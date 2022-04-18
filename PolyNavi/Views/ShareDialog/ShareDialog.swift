//
//  ShareDialog.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.04.2022.
//

import SwiftUI

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
                
                CodeVariant(enabled: Binding<Bool>(get: { !isQR }, set: { _ in }), title: "AppClip", image: Image(systemName: "appclip"))
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
                ForEach(ShareDialog.ColorVariant.allCases) { color in
                    Button(action: {
                        
                        colorVariant = color
                    }, label: {
                        HStack {
                            Text(color.rawValue).foregroundColor(.primary)
                            Spacer()
                            if colorVariant == color {
                                Image(systemName: "checkmark").foregroundColor(.accentColor)
                            }
                        }
                    })
                }
            }
        }, label: {
            HStack {
                Text("Color")
                Spacer()
                Text(colorVariant.rawValue).foregroundColor(.secondary)
            }
        })
    }
}

struct ShareDialog: View {
    
    enum ColorVariant: String, CaseIterable, Identifiable {
        case red, white, yellow
        
        var id: Self { self }
    }
    
    @State var isQR: Bool = false
    @State var showHelloText: Bool = false
    @State var helloText: String = ""
    @State var colorVariant: ColorVariant = .white
    
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
                }
                
                Section {
                    HStack {
                        Spacer()
                        ZStack {
                            NavigationLink(destination: { Text("RESULT") }, label: { EmptyView() })
                                .opacity(0.0)
                            RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 200)
                                    .foregroundColor(.accentColor)
                            Text("Создать")
                                    .padding(.vertical, 9.0)
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
                            }
                        Spacer()
                    }.listRowBackground(Color.clear)
                }
            }
            .navigationBarTitle("Создание кода", displayMode: .inline)
        }
        .navigationViewStyle(.stack)
    }
}

struct ShareDialog_Previews: PreviewProvider {
    static var previews: some View {
        ShareDialog()
            .environment(\.colorScheme, .dark)
    }
}

//
//  ShareResult.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 19.04.2022.
//

import SwiftUI
import Alamofire

struct ActivityViewController: UIViewControllerRepresentable {
    
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            self.presentationMode.wrappedValue.dismiss()
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) { }
    
}

struct ShareResultLine: View {
    @State var share: [Any]
    @State var title: String
    @State var show: Bool = false
    
    var body: some View {
        Button(action: {
            show.toggle()
        }, label: {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "square.and.arrow.up")
                    .resizable(resizingMode: .tile)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
            }
        })
            .sheet(isPresented: $show, onDismiss: nil, content: {
                ActivityViewController(activityItems: share)
            })
    }
    
}

struct ShareResult: View {
    @State var result: UIImage? = nil
    @State var show: Bool = false
    @State var settings: ShareDialog.Settings
    @State var response: CodeGeneratorModel.GenerateResponse?
    
    var body: some View {
        VStack {
            if result != nil {
                List {
                    Section {
                        HStack
                        {
                            Spacer()
                            Image(uiImage: result ?? UIImage(systemName: "xmark.octagon")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 200)
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    }
                    
                    ShareResultLine(share: [ result ?? UIImage() ], title: "Растровое изображение PNG")
                    ShareResultLine(share: [ result ?? UIImage() ], title: "Векторное изображение SVG")
                    ShareResultLine(share: [ result ?? UIImage() ], title: "Рекомендации по использованию PDF")
                                       
                    Section {
                        ShareResultLine(share: [ response?.codeUrl ?? "error" ], title: "Постоянная ссылка")
                    }
                }
            } else {
                if #available(iOS 14.0, *) {
                    ProgressView()
                } else {
                    Text("Loading...")
                }
            }
        }.onAppear(perform: {
            
            CodeGeneratorProvider.generateCode(isQR: settings.isQR, from: settings.from, to: settings.to, text: settings.text, completion: { res in
                if let res = res.data {
                    response = res
                    CodeGeneratorProvider.loadAppclip(id: res.appClipID, colorVariant: settings.color, logoVariant: settings.logo, badgeVariant: settings.bage, completion: { res in
                        if let img = res.data {
                            result = img
                        } else {
                            print("Error load image")
                        }
                    })
                } else {
                    print("Error generate")
                }
            })
        })
    }
}

struct ShareResult_Previews: PreviewProvider {
    static var previews: some View {
        ShareResult(settings:  .init(color: .blackL, logo: .camera, bage: .circle, isQR: false, from: UUID(), to: UUID(), text: ""))
            .environment(\.colorScheme, .dark)
    }
}

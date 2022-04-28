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

struct SharePngResultLine: View {
    @State var title: String
    @State var show: Bool = false
    @Binding var result: ApiStatus<Any>?
    
    var body: some View {
        Button(action: {
            show.toggle()
        }, label: {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                if result == nil {
                    ActivityIndicator(style: .medium)
                } else {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                }
            }
        })
            .sheet(isPresented: $show, onDismiss: nil, content: {
                ActivityViewController(activityItems: [result!.data!])
            })
    }
    
}

struct ShareResult: View {
    @State var result: UIImage? = nil
    @State var show: Bool = false
    @State var settings: ShareDialog.Settings
    @State var response: CodeGeneratorModel.GenerateResponse?
    
    @State var svg: ApiStatus<Any>?
    @State var png: ApiStatus<Any>?
    
    @State var tutorial: URL?
    
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
                                .frame(maxWidth: 250)
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    }
                    SharePngResultLine(title: L10n.Share.Result.sharePng, result: $png)
                    SharePngResultLine(title: L10n.Share.Result.shareSvg, result: $svg)
                    if let tutorial = tutorial {
                        Button(action: {
                            UIApplication.shared.open(tutorial)
                        }, label: {
                            HStack {
                                Text(L10n.Share.Result.sharePdf)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "safari")
                                    .font(.system(size: 20))
                            }
                        })
                    }
                    
                    if let response = response {
                        Section(footer: Text(L10n.Share.Result.ShareUrl.info)) {
                            SharePngResultLine(title: L10n.Share.Result.shareUrl, result: .constant(ApiStatus.successWith(response.codeUrl)))
                        }
                    }
                    

                }
            } else {
                if #available(iOS 14.0, *) {
                    ProgressView()
                } else {
                    Text(L10n.Share.Result.loading)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(L10n.Share.Result.navigationTitle)
        .navigationBarItems(trailing: Button(action: {
            dismiss(animated: true)
        }, label: { Text(L10n.Share.Result.done) } ))
        .onAppear(perform: {
        
            let cast: (ApiStatus<URL>) -> (ApiStatus<Any>) = { res in
                switch res {
                case .successWith(let t):
                    return .successWith(t)
                case .errorNoInternet:
                    return .errorNoInternet
                case .error:
                    return .error
                }
            }
            
            CodeGeneratorProvider.generateCode(isQR: settings.isQR, from: settings.from, to: settings.to, text: settings.text, completion: { res in
                if let res = res.data {
                    response = res
                    tutorial = CodeGeneratorProvider.tutorialUrl(id: res.appClipID, colorVariant: settings.color, logoVariant: settings.logo, badgeVariant: settings.bage)
                    
                    CodeGeneratorProvider.loadAppclip(id: res.appClipID, colorVariant: settings.color, logoVariant: settings.logo, badgeVariant: settings.bage, svg: false, width: 512, completion: { res in
                        if let url = res.data,
                           let data = try? Data(contentsOf: url),
                           let img = UIImage(data: data) {
                            result = img
                        } else {
                            print("Error load image")
                        }
                    })
                    
                    CodeGeneratorProvider.loadAppclip(id: res.appClipID, colorVariant: settings.color, logoVariant: settings.logo, badgeVariant: settings.bage, svg: true, completion: {
                        svg = cast($0)
                    })
                    
                    CodeGeneratorProvider.loadAppclip(id: res.appClipID, colorVariant: settings.color, logoVariant: settings.logo, badgeVariant: settings.bage, svg: false, width: 2048, completion: {
                        png = cast($0)
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
        ShareResult(settings:  .init(color: .greenWhite, logo: .camera, bage: .circle, isQR: false, from: UUID(), to: UUID(), text: ""))
            .environment(\.colorScheme, .dark)
    }
}

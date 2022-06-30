//
//  EmptyBuildingPlan.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 08.05.2022.
//

import SwiftUI
import UIKit
import MessageUI

struct MailView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    var message: String
    var subject: String
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        
        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(presentation: Binding<PresentationMode>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation,
                           result: $result)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(["soprachev@mail.ru"])
        vc.setSubject(subject)
        vc.setMessageBody(message, isHTML: false)
        
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {
        
    }
}


struct EmptyBuildingPlan: View {
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    
    var buildingName: String
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 50) {
                    Text(L10n.MapInfo.Detail.EmptyPlan.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 40.0)
                    VStack(alignment: .leading, spacing: 20) {
                        Text(L10n.MapInfo.Detail.EmptyPlan.message)
                        Text("soprachev@mail.ru")
                            .contextMenu {
                                Button(action: { UIPasteboard.general.string = "soprachev@mail.ru" }, label: {
                                    Text(L10n.MapInfo.Detail.EmptyPlan.Email.copy)
                                })
                                
                                Button(action: { self.isShowingMailView.toggle() }, label: {
                                    Text(L10n.MapInfo.Detail.EmptyPlan.Email.open)
                                })
                            }
                    }
                }
                Spacer()
                Button(action: {
                    self.isShowingMailView.toggle()
                }, label: {
                    Text(L10n.MapInfo.Detail.EmptyPlan.open)
                        .font(.headline)
                        .frame(maxWidth: 300)
                        .frame(height: 46)
                })
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .background(MFMailComposeViewController.canSendMail() ? Color(Asset.accentColor.color) : .secondary)
                    .cornerRadius(10)
                    .disabled(!MFMailComposeViewController.canSendMail())
            }
            .padding(.horizontal, 20)
            .padding(.bottom)
            .frame(maxWidth: 500)
            .navigationBarItems(leading: Button(action: {
                dismiss(animated: true)
            }, label: { Text(L10n.Present.cancel) } ))
            .navigationBarTitle("", displayMode: .inline)
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $isShowingMailView) {
            MailView(result: self.$result,
                     message: L10n.MapInfo.Detail.EmptyPlan.Mail.message.replacingOccurrences(of: "{BUILDING}", with: buildingName),
                     subject: L10n.MapInfo.Detail.EmptyPlan.Mail.subject)
        }
    }
}

struct EmptyBuildingPlan_Previews: PreviewProvider {
    static var previews: some View {
        EmptyBuildingPlan(buildingName: "")
            
    }
}

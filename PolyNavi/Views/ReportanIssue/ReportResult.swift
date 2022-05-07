//
//  ReportResult.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 07.05.2022.
//

import SwiftUI

struct ReportResult: View {
    var reportText: String = ""
    var report: SectionCollection.Report.ReportBase
    
    @State var result: ApiStatus<ReportApiProvider.Result>? = nil
    
    var body: some View {
        VStack {
            if result != nil {
                if result?.data != nil {
                    Image(systemName: "checkmark.bubble")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(50.0)
                        .frame(maxWidth: 400)
                        .foregroundColor(.accentColor)
                        .font(.title.weight(.thin))
                    Text(L10n.ReportAnIssue.succes)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20.0)
                    
                    Image(systemName: "checkmark.bubble")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(50.0)
                        .frame(maxWidth: 400)
                        .foregroundColor(.clear)
                        .font(.title.weight(.thin))
                    
                } else {
                    VStack {
                        Image(systemName: "xmark.octagon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(50.0)
                            .frame(maxWidth: 400)
                            .foregroundColor(.accentColor)
                            .font(.title.weight(.thin))
                        Text(L10n.ReportAnIssue.serverError)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20.0)
                        
                        Image(systemName: "xmark.octagon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(50.0)
                            .frame(maxWidth: 400)
                            .foregroundColor(.clear)
                            .font(.title.weight(.thin))
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
        .navigationBarBackButtonHidden(!(result != nil && result?.data == nil))
        .navigationBarItems(trailing: Button(action: {
            dismiss(animated: true)
        }, label: { Text(L10n.Share.Result.done) } ))
        .onAppear(perform: {
            ReportApiProvider.sendReport(message: reportText, report: report, completion: { res in
                self.result = res
            })
        })
    }
}

struct ReportResult_Previews: PreviewProvider {
    static var previews: some View {
        ReportResult(reportText: "", report: SectionCollection.Report.ReportAnnotation(annotation: EnviromentAmenityAnnotation(coordinate: .init(latitude: 0, longitude: 0), imdfID: UUID(), properties: .init(name: nil, alt_name: nil, category: .banch, detailLevel: 1), detailLevel: 1)))
    }
}

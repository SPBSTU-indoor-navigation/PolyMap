//
//  ReportanIssue.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 06.05.2022.
//

import SwiftUI

struct ReportanIssue: View {
    @State var reportText: String = ""

    var report: SectionCollection.Report.ReportBase
    
    func mainView(scroll: ((String) -> Void)? = nil) -> some View {
        
        func topInfo() -> some View  {
            if let report = report as? SectionCollection.Report.ReportAnnotation {
                return AnyView(Section(content: {
                    SearchablePreview(searchable: report.annotation)
                        .padding(.vertical, 5)
                }, header: { Text(L10n.ReportAnIssue.Error.route) }))
                
            } else if let report = report as? SectionCollection.Report.ReportRoute {
                return AnyView(Section(content: {
                    HStack {
                        Text(L10n.MapInfo.Route.Info.from)
                        SearchablePreview(searchable: report.from)
                            .padding(.vertical, 5)
                    }
                    
                    HStack {
                        Text(L10n.MapInfo.Route.Info.to)
                        SearchablePreview(searchable: report.to)
                            .padding(.vertical, 5)
                    }
                    
                    HStack {
                        Text("\(L10n.MapInfo.Route.Info.asphalt): \(report.params.asphalt ? L10n.ReportAnIssue.enable : L10n.ReportAnIssue.disable)")
                    }
                    HStack {
                        Text("\(L10n.MapInfo.Route.Info.serviceRoute): \(report.params.serviceRoute ? L10n.ReportAnIssue.enable : L10n.ReportAnIssue.disable)")
                    }
                }, header: { Text(L10n.ReportAnIssue.Error.route) }))
            }
            
            return AnyView(Section { Text("ERROR ISSUE TYPE") })
        }
        
        return List {
            topInfo()
            
            Section(content: {
                TextViewPlaceholder(text: $reportText, placehodler: L10n.ReportAnIssue.Message.placeholder, beginEdit: {
                    scroll?("reportText")
                })
                    .frame(height: 200)
            }, header: {
                Text(L10n.ReportAnIssue.Message.title)
            }, footer: {
                Text(L10n.ReportAnIssue.Message.footer)
            }).id("reportText")
            
            Section {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: 400)
                    .listRowBackground(Color.clear)
            }
                
        }
        .navigationBarTitle("\(L10n.ReportAnIssue.title)", displayMode: .inline)
        .navigationBarItems(trailing:
                                NavigationLink(destination: { ReportResult(reportText: reportText, report: report) },
                                               label: { Text(L10n.ReportAnIssue.send) })
                                .disabled(reportText.isEmpty))
        .onAppear(perform: {
            UIScrollView.appearance().keyboardDismissMode = .onDrag
        })
    }
    
    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                ScrollViewReader { proxy in
                    mainView(scroll: { id in
                        withAnimation {
                            proxy.scrollTo(id, anchor: .top)
                        }
                    })
                }
            } else {
                mainView()
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct ReportanIssue_Previews: PreviewProvider {
    static var previews: some View {
//        ReportanIssue(report: SectionCollection.Report.ReportAnnotation(annotation: EnviromentAmenityAnnotation(coordinate: .init(latitude: 0, longitude: 0), imdfID: UUID(), properties: .init(name: nil, alt_name: nil, category: .banch, detailLevel: 1), detailLevel: 1)))
        
        ReportanIssue(report: SectionCollection.Report.ReportRoute(
            from: EnviromentAmenityAnnotation(coordinate: .init(latitude: 0, longitude: 0), imdfID: UUID(), properties: .init(name: nil, alt_name: nil, category: .banch, detailLevel: 1), detailLevel: 1),
            to: EnviromentAmenityAnnotation(coordinate: .init(latitude: 0, longitude: 0), imdfID: UUID(), properties: .init(name: nil, alt_name: nil, category: .banch, detailLevel: 1), detailLevel: 1),
            params: .init(asphalt: false, serviceRoute: true)))
    }
}

//
//  ReportanIssue.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 06.05.2022.
//

import SwiftUI

struct ReportanIssue: View {
    var report: SectionCollection.Report.ReportBase
    
    var body: some View {
        NavigationView {
            
            Text("Hello, World!")
        }
        .navigationBarTitle("Report", displayMode: .inline)
    }
}

struct ReportanIssue_Previews: PreviewProvider {
    static var previews: some View {
        ReportanIssue(report: SectionCollection.Report.ReportAnnotation(annotation: EnviromentAmenityAnnotation(coordinate: .init(latitude: 0, longitude: 0), imdfID: UUID(), properties: .init(name: nil, alt_name: nil, category: .banch, detailLevel: 1), detailLevel: 1)))
    }
}

//
//  OpenUrlPopupContent.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 23.04.2022.
//

import SwiftUI

struct OpenUrlPopupContent: View {
    @Binding var data: CodeGeneratorModel.DataResponse
    @State var from: Searchable? = nil
    @State var to: Searchable? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text(L10n.Share.OpenURL.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40.0)
                .padding(.bottom, 30)
            
            VStack(alignment: .leading) {
                Text(L10n.Share.OpenURL.info)
                
                if let from = from,// ?? SearchablePreview_Previews.Mock(),
                   let to = to //?? SearchablePreview_Previews.Mock()
                {
                    VStack {
                        HStack {
                            Text(L10n.MapInfo.Route.Info.from)
                            SearchablePreview(searchable: from)
                        }
                        Divider()
                        HStack {
                            Text(L10n.MapInfo.Route.Info.to)
                            SearchablePreview(searchable: to)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .foregroundColor(Color(UIColor.secondarySystemBackground))
                    )
                }
                
                if !data.helloText.isEmpty {
                    HStack(alignment: .top) {
                        Image(systemName: "text.bubble")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.accentColor)
                            .frame(width: 40, height: 40)
                            .padding(.trailing)
                        VStack(alignment: .leading) {
                            Text(L10n.Share.OpenURL.message)
                                .font(.headline)
                            Text(data.helloText)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top)
                }
                
            }.frame(maxWidth: 500)
            
            Spacer()
            
            Text(L10n.Share.OpenURL.openInfo)
                .foregroundColor(.secondary)
                .font(.footnote)
                .padding(.horizontal, 20)
                
            
            Button(action: {
                if let from = from?.annotation,
                   let to = to?.annotation {
                        MapInfo.exclusiveRouteDetail?.show(from: from, to: to)
                    }
                
                DispatchQueue.main.async {
                    dismiss(animated: true)
                }
            }, label: {
                Text(L10n.Share.OpenURL.continue)
                    .font(.headline)
                    .frame(maxWidth: 300)
                    .frame(height: 46)
            })
                .foregroundColor(.white)
                .background(Color(Asset.accentColor.color))
                .cornerRadius(10)
        }
        .padding()
        .onAppear(perform: {
            if let from = PathFinder.shared.annotationById[data.from] as? Searchable,
               let to = PathFinder.shared.annotationById[data.to] as? Searchable {
                self.from = from
                self.to = to
            } else {
                dismiss(animated: true)
            }
        })
    }
}

struct OpenUrlPopupContent_Previews: PreviewProvider {
    static var previews: some View {
        OpenUrlPopupContent(data: .constant(.init(from: UUID(), to: UUID(), helloText: "hello world\ngg\n\nb\nrtgtg")))
            .preferredColorScheme(.dark)
            .previewLayout(PreviewLayout.sizeThatFits)
            .frame(width: 600, height: 900)
    }
}

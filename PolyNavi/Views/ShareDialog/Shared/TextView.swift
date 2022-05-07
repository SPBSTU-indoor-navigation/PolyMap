//
//  TextView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 18.04.2022.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    @Binding var text: String
    
    typealias UIViewType = UITextView
    var configuration = { (view: UIViewType) in }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        let t = UIViewType()
        t.delegate = context.coordinator
        return t
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)
        uiView.text = text
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        
        var parent: TextView
        
        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if textView.markedTextRange == nil {
                parent.text = textView.text ?? String()
            }
        }
    }
}

struct TextViewPlaceholder: View {
    @Binding var text: String
    var placehodler: String
    var beginEdit: (()->Void)?
    
    var body: some View {
        ZStack {
            if text.isEmpty {
                VStack{
                    HStack{
                        Text(placehodler)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    Spacer()
                }
            }
            
            TextView(text: $text) {
                $0.backgroundColor = .clear
                $0.clipsToBounds = false
                $0.textContainerInset = .zero
                $0.textContainer.lineFragmentPadding = 0
                $0.font = .preferredFont(forTextStyle: .body)
            }
            .onTapGesture {
                beginEdit?()
            }
        }
    }
}

//
//  CreatedByDetail.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 26.09.2024.
//

import SwiftUI

struct CreatedByDetail: View {
    @Environment(\.colorScheme) var colorScheme
    
    var title: String
    var description: String
    var authorsTitle: String
    var authors: [String]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(title)
                            .font(.largeTitle)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(description)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if !authors.isEmpty {
                        VStack {
                            if !authorsTitle.isEmpty {
                                Text(authorsTitle)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            VStack {
                                ForEach(authors, id: \.self) { author in
                                    Text(author)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    if author != authors.last { Divider() }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background {
                                Rectangle()
                                    .cornerRadius(10)
                                    .foregroundStyle(Color(colorScheme == .dark ? .secondarySystemGroupedBackground : .systemGroupedBackground))
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    CreatedByDetail(title: "Участники отрисовки 1-2 учебного корпуса",
                    description: "Планировка этого здания перенесена в PolyMap студентами Санкт-Петербургского Политехнического Университета в рамках курса Остновы Проектной Деятельности 2024 года.\n\nЧлены команды перенесли инженерные планы в цифровой формат, проложили граф маршрутов и расставили аннотации с актуальными номерами кабинетов.",
                    authorsTitle: "Команда",
                    authors: [
                        "Сопрачев Андрей Константинович1",
                        "Сопрачев Андрей Константинович2",
                        "Сопрачев Андрей Константинович3",
                    ])
}

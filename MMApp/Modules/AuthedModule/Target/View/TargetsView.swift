//
//  TargetsView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import Foundation
import SwiftUI

struct TargetsView: View {
    @State var targets: [UserTarget] = [] // Состояние для всех целей
    @State private var isEditingCategory: Bool = false
    @State private var selectedCategory: UserTarget.Category? = nil
    @State private var selectedTab = 1

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                Picker("Key", selection: $selectedTab) {
                    Text("Список").tag(0)
                    Text("Статистика").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                if selectedTab == 0 {
                    ScrollView {
                        LazyVStack {
                            ForEach(UserTarget.Category.allCases, id: \.self) { category in
                                let filteredTargets = targets.filter { $0.category == category }
                                if !filteredTargets.isEmpty {
                                    CategorySectionView(
                                        category: category,
                                        targets: filteredTargets,
                                        onEdit: {
                                            selectedCategory = category
                                            isEditingCategory = true
                                        }
                                    )
                                }
                            }
                        }
                        .padding()
                    }
                    .sheet(isPresented: $isEditingCategory) {
                        if let category = selectedCategory {
                            CategoryEditView(
                                category: category,
                                targets: $targets, // Передаем Binding к списку целей
                                isPresented: $isEditingCategory
                            )
                        }
                    }
                    .onAppear {
                        loadTargets()
                    }
                } else {
                    Text("DGFD")
                        .foregroundColor(.mainRed)
                    Spacer()
                }
            }
            .navigationTitle("Цели")
        }
    }
}

#Preview {
    TargetsView()
}

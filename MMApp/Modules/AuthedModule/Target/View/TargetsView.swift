//
//  TargetsView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import Foundation
import SwiftUI

struct TargetsView: View {
    @StateObject private var viewModel = TargetsViewModel()
    @State private var isEditingCategory: Bool = false
    @State private var selectedCategory: TargetCategory? = nil
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                Picker("Key", selection: $selectedTab) {
                    Text("Список").tag(0)
                    Text("Статистика").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                if selectedTab == 0 {
                    ScrollView {
                        LazyVStack {
                            ForEach(TargetCategory.allCases, id: \.self) { category in
                                categorySectionView(for: category)
                            }
                        }
                        .padding()
                    }
                    .sheet(isPresented: $isEditingCategory) {
                        if let category = selectedCategory {
                            CategoryEditView(
                                category: category,
                                clusedSubTarget: $viewModel.clusedSubTarget,
                                targets: $viewModel.targets, // Передаем Binding к списку целей
                                isPresented: $isEditingCategory
                            )
                        }
                    }
                    .onAppear {
                        viewModel.loadTargets()
                    }
                } else {
                    StatisticTargetScreen(viewModel: viewModel)
                }
            }
            .navigationTitle("Цели")
        }
    }
    
    @ViewBuilder
    private func categorySectionView(for category: TargetCategory) -> some View {
        let targets = filteredTargets(for: category) // Используем вынесенный метод
        
        if !targets.isEmpty {
            CategorySectionView(
                clusedSubTarget: $viewModel.clusedSubTarget,
                category: category,
                targets: targets.map({$0.wrappedValue}),
                onEdit: {
                    selectedCategory = category
                    isEditingCategory = true
                }
            )
        }
    }
    
    private func filteredTargets(for category: TargetCategory) -> [Binding<UserTargetDtoModel>] {
        viewModel.targets.indices.compactMap { index -> Binding<UserTargetDtoModel>? in
            viewModel.targets[index].category == category ? $viewModel.targets[index] : nil
        }
    }
}

#Preview {
    TargetsView()
}

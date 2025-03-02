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
                
                if viewModel.targets.isEmpty, !viewModel.isLoading  {
                    Spacer()
                    Text("У вас пока нет целей")
                        .font(.headline)
                        .foregroundColor(.headerText)
                        .padding()
                    Spacer()
                } else {
                    Picker("Key", selection: $selectedTab) {
                        Text("Список").tag(0)
                        Text("Статистика").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    if viewModel.isLoading {
                        shimerView()
                    } else {
                        if selectedTab == 0 {
                            ScrollView {
                                LazyVStack {
                                    ForEach(TargetCategory.allCases, id: \.self) { category in
                                        categorySectionView(for: category)
                                    }
                                }
                                .padding()
                            }
                            .refreshable {
                                withAnimation {
                                    viewModel.loadTargets()
                                }
                            }
                            .sheet(isPresented: $isEditingCategory) {
                                if let category = selectedCategory {
                                    CategoryEditView(
                                        category: category,
                                        targets: $viewModel.targets, // Передаем Binding к списку целей
                                        isPresented: $isEditingCategory
                                    )
                                }
                            }
                        } else {
                            StatisticTargetScreen(viewModel: viewModel)
                        }
                    }
                }
            }
            .onAppear {
                if viewModel.targets.isEmpty {
                    viewModel.loadTargets()
                }
            }
            .environmentObject(viewModel)
            .navigationTitle("Цели")
        }
        .onChange(of: viewModel.targets, {
            print("Изменилась target")
        })
    }
    
    @ViewBuilder
    private func shimerView() -> some View {
        VStack(spacing: 8) {
            ShimmeringRectangle()
                .frame(height: 40)
                .cornerRadius(8)
                .padding(.top, 20)
            
            ShimmeringRectangle()
                .frame(height: 40)
                .cornerRadius(8)
                .padding(.top, 20)
            
            ShimmeringRectangle()
                .frame(height: 40)
                .cornerRadius(8)
                .padding(.top, 20)
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func categorySectionView(for category: TargetCategory) -> some View {
        if let filtredTarget = viewModel.groupedTargets[category],
            !filtredTarget.isEmpty {
            CategorySectionView(
                category: category,
                targets: filtredTarget,
                onEdit: {
                    selectedCategory = category
                    isEditingCategory = true
                }
            )
            .onChange(of: viewModel.targets, {
                print("Изменилась TargetsView categorySectionView")
            })
        }
    }
    
    private func filteredTargets(for category: TargetCategory) -> Binding<[UserTargetDtoModel]> {
        Binding(
            get: { viewModel.targets.filter { $0.category == category } },
            set: { newValue in
                for target in newValue {
                    if let index = viewModel.targets.firstIndex(where: { $0.id == target.id }) {
                        viewModel.targets[index] = target
                    }
                }
            }
        )
    }
}

#Preview {
    TargetsView()
}

//
//  TargetsView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import Foundation
import SwiftUI

struct TargetsView: View {
    @StateObject private var viewModel = TargetsViewModel()//.mockWithData()
    @State private var isEditingCategory: Bool = false
    @State private var selectedCategory: TargetCategory? = nil
    @State private var selectedTab = 0
    @State private var showAddTarget = false
    @State private var showErrorAlert = false
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.targets.isEmpty {
                    shimerView()
                } else if viewModel.targets.isEmpty {
                    emptyStateView()
                } else {
                    mainContentView()
                }
            }
            .navigationTitle("Цели")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddTarget = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.mainRed)
                    }
                }
            }
            .sheet(isPresented: $showAddTarget) {
                AddTargetView(onSave: { target in
                    Task {
                        await viewModel.saveTarget(target, isCreateTarget: true)
                    }
                    showAddTarget = false
                })
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Ошибка"),
                    message: Text(viewModel.errorMessage ?? "Произошла неизвестная ошибка"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                if viewModel.targets.isEmpty {
                    viewModel.loadTargets()
                }
            }
            .environmentObject(viewModel)
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            showErrorAlert = newValue != nil
        }
    }
    
    // MARK: - Empty State View
    @ViewBuilder
    private func emptyStateView() -> some View {
        VStack {
            Spacer()
            Image(systemName: "checkmark.circle.badge.xmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
            
            Text("У вас пока нет целей")
                .font(.headline)
                .foregroundColor(.headerText)
                .padding(.bottom, 4)
            
            Text("Создайте свою первую цель, чтобы отслеживать прогресс")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button(action: {
                showAddTarget = true
            }) {
                Text("Создать цель")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.mainRed)
                    .cornerRadius(8)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Main Content View
    @ViewBuilder
    private func mainContentView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Диаграмма статистики
                statisticsView()
                    .padding(.top, 8)
                
                // Категории целей
                categoriesView()
            }
            .padding(.horizontal)
        }
        .refreshable {
            await MainActor.run {
                viewModel.loadTargets()
            }
        }
    }
    
    // MARK: - Statistics View
    @ViewBuilder
    private func statisticsView() -> some View {
        StatisticsView(
            tasks: viewModel.tasksItems.isEmpty ?
                TargetCategory.allCases.map { category in
                    TaskProgress(
                        progress: 0,
                        color: category.color,
                        name: category.rawValue,
                        value: 0
                    )
                } : viewModel.tasksItems,
            selectedCategory: $selectedCategory
        )
    }
    
    // MARK: - Categories View
    @ViewBuilder
    private func categoriesView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if let selectedCategory = selectedCategory {
                // Если выбрана определенная категория, показываем только ее
                if let targets = viewModel.groupedTargets[selectedCategory], !targets.isEmpty {
                    Text("Категория: \(selectedCategory.rawValue)")
                        .font(.headline)
                        .foregroundColor(.headerText)
                        .padding(.leading, 8)
                    
                    categoryTargetsView(category: selectedCategory)
                    
                    Button("Показать все категории") {
                        self.selectedCategory = nil
                    }
                    .font(.subheadline)
                    .foregroundColor(.mainRed)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            } else {
                // Показываем все категории
                ForEach(TargetCategory.allCases, id: \.self) { category in
                    categorySectionView(for: category)
                }
            }
        }
    }
    
    // MARK: - Category Targets View
    @ViewBuilder
    private func categoryTargetsView(category: TargetCategory) -> some View {
        if let targets = viewModel.groupedTargets[category], !targets.isEmpty {
            VStack(spacing: 12) {
                ForEach(targets) { target in
                    TargetRowView<TargetsViewModel>(
                        myTarget: true,
                        target: target
                    )
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.deleteTarget(target: target)
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Shimer Loading View
    @ViewBuilder
    private func shimerView() -> some View {
        VStack(spacing: 8) {
            // Имитация диаграммы
            ShimmeringRectangle()
                .frame(height: 180)
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.top, 20)
            
            // Имитация категорий
            ForEach(0..<3, id: \.self) { _ in
                ShimmeringRectangle()
                    .frame(height: 40)
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func categorySectionView(for category: TargetCategory) -> some View {
        if let filteredTarget = viewModel.groupedTargets[category],
           !filteredTarget.isEmpty {
            CategorySectionView(
                category: category,
                targets: filteredTarget,
                onEdit: {
                    selectedCategory = category
                    isEditingCategory = true
                }
            )
        }
    }
}

#Preview {
    TargetsView()
}

// MARK: - Превью с моковыми данными
struct MockTargetsView: View {
    var body: some View {
        TargetsView()
    }
}

#Preview {
    MockTargetsView()
}

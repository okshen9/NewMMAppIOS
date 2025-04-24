//
//  TargetsView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import Foundation
import SwiftUI

struct TargetsView: View {
    @StateObject private var viewModel = TargetsViewModel.mockWithData()
    @State private var isEditingCategory: Bool = false
    @State private var selectedCategory: TargetCategory? = nil
    @State private var currentChartLevel: Int = 0 // Отслеживаем текущий уровень диаграммы
    @State private var showAddTarget = false
    @State private var showErrorAlert = false
    @State private var currentLevelItemsCount: Int = 0 // Добавляем состояние
    
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
            VStack(alignment: .leading, spacing: 20) {
                // Диаграмма статистики как обычный первый элемент
                statisticsView()
                    .padding(.top, 8)
                
                // Разделительная линия
                Divider()

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
        VStack(alignment: .center, spacing: 10) {
            Text("Статистика по категориям")
                .font(.headline)
                .foregroundColor(.headerText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
                
            let screenWidth = UIScreen.main.bounds.width
            let chartSize = screenWidth - 32
                
            // Проверка, есть ли у нас данные
            if viewModel.pieModels.isEmpty {
                Text("Загрузка данных...")
                    .foregroundColor(.secondary)
                    .frame(height: 100)
            } else {
                // Используем NewPieDiagram с адаптивной высотой
                NewPieDiagram(
                    slices: viewModel.pieModels,
                    segmentSpacing: 0.02,
                    cornerRadius: 8,
                    title: "Выполнение целей",
                    legendOnSide: false,
                    showCenterLabel: .constant(true),
                    isInteractive: .constant(true),
                    currentItemsCount: $currentLevelItemsCount,
                    onSectorSelected: { model in
                        // Обрабатываем выбор сектора
                        if let category = TargetCategory.allCases.first(where: { $0.rawValue == model.title }) {
                            withAnimation {
                                selectedCategory = category
                            }
                        }
                    }
                )
                .frame(width: chartSize)
                .frame(height: calculateDiagramHeight(chartSize: chartSize, itemsCount: currentLevelItemsCount).animatableData)
                .onChange(of: currentChartLevel) { oldValue, newValue in
                    // Если возвращаемся на верхний уровень, то сбрасываем выбранную категорию
                    if newValue == 0 && oldValue > 0 {
                        withAnimation {
                            selectedCategory = nil
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PieChartLevelChanged"))) { notification in
                    if let level = notification.object as? Int {
                        currentChartLevel = level
                    }
                }
            }
        }
        .onChange(of: viewModel.pieModels) { _, newModels in
            // Обновляем выбранную категорию, если она больше не существует в данных
            if let selectedCategory = selectedCategory, 
               !newModels.contains(where: { $0.title == selectedCategory.rawValue }) {
                self.selectedCategory = nil
            }
        }
        .onChange(of: selectedCategory) { oldValue, newValue in
            // Обновляем выбранную категорию в диаграмме, 
            // когда категория выбирается из списка
            if newValue == nil && oldValue != nil && currentChartLevel > 0 {
                // Уведомляем диаграмму, что нужно вернуться на верхний уровень
                NotificationCenter.default.post(
                    name: NSNotification.Name("ResetPieChartLevel"),
                    object: nil
                )
            }
        }
    }
    
    // Функция для расчета высоты диаграммы
    private func calculateDiagramHeight(chartSize: CGFloat, itemsCount: Int) -> CGFloat {
        let itemsPerRow = Int(UIScreen.main.bounds.width / (160 + 16 + 10)) // Примерная ширина элемента
        let rowsCount = itemsCount <= itemsPerRow ? 1 : 2
        let legendHeight: CGFloat = rowsCount == 1 ? 40 : 80 // Высота легенды в зависимости от количества строк
        return chartSize + legendHeight
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

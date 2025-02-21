//
//  StatisticTargetScreen.swift
//  MMApp
//
//  Created by artem on 06.02.2025.
//

import SwiftUI
import Foundation

struct StatisticTargetScreen: View {
    @ObservedObject var viewModel: TargetsViewModel
    // TODO: Убрать TargetsView
    @State var category: String = "Все категории"
    @State var selectedFractal: PiaViewFractionModel? = nil
    
    @State private var isEditingCategory: Bool = false
    @State private var selectedCategory: TargetCategory? = nil
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PiaView(piaMdels: mapTargetsToFractal(viewModel.targets),
                        selectedFract: $selectedFractal)
                .frame(width: UIScreen.main.bounds.width - 32,
                       height: UIScreen.main.bounds.width - 32
                )
                LazyVStack {
                    let categorys = selectedCategory.isNil ? TargetCategory.allCases : [selectedCategory!]
                    ForEach(categorys, id: \.self) { category in
                            categorySectionView(for: category)
                    }
                }
                
            }
        }
        .onChange(of: selectedFractal) {
            print($0?.name ?? "Error")
            guard let categoryName = $0?.name else {
                selectedCategory = nil
                return
            }
            print("selectedFractal \(categoryName)")
            selectedCategory =  TargetCategory(rawValue: categoryName)
        }
        .padding(16)
    }
        
    
    func mapTargetsToFractal(_ targets: [UserTargetDtoModel]) -> [PiaViewFractionModel] {
        var piaModel = [PiaViewFractionModel]()

        for category in TargetCategory.allCases {
            // Фильтруем цели по категории
            let filteredTargets = targets.filter { $0.category == category }

            // Получаем список всех подцелей
            let allSubTargets = filteredTargets.flatMap { $0.subTargets ?? [] }

            // Вычисляем количество завершённых подцелей
            let completedSubTargets = allSubTargets.filter { $0.targetStatus == .done }.count

            // Общее количество подцелей
            let totalSubTargets = allSubTargets.count

            // Добавляем модель
            piaModel.append(
                PiaViewFractionModel(
                    color: category.color,
                    allStats: Double(totalSubTargets),
                    currnetValue: Double(completedSubTargets),
                    name: category.rawValue
                )
            )
        }
        return piaModel
    }

    
    @ViewBuilder
    private func categorySectionView(for category: TargetCategory) -> some View {
        var targets = filteredTargets(for: category) // Используем вынесенный метод
        if !targets.isEmpty {
            CategorySectionView(
                clusedSubTarget: $viewModel.clusedSubTarget,
                clusedTarget: $viewModel.clusedTarget,
                category: category,
                targets: targets,
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
    StatisticTargetScreen(viewModel: TargetsViewModel())
}



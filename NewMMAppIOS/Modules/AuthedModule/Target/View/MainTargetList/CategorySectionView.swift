//
//  CategorySectionView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

struct CategorySectionView: View {
    var myTarget = true
    var category: TargetCategory
    var targets: [UserTargetDtoModel] // Список целей для выбранной категории
    @State var onEdit: () -> Void // Замыкание для редактирования категории
    @EnvironmentObject var viewModel: TargetsViewModel
    
    // Константы для дизайна
    private let categoryIndicatorSize: CGFloat = 32
    private let targetIndicatorSize: CGFloat = 24
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок категории с индикатором
            HStack(spacing: 12) {
                // Индикатор категории
                ZStack {
                    // Фоновое свечение
                    Circle()
                        .fill(category.color.opacity(0.2))
                        .frame(width: categoryIndicatorSize + 8, height: categoryIndicatorSize + 8)
                        .blur(radius: 4)
                    
                    // Основной круг
                    Circle()
                        .fill(category.color)
                        .frame(width: categoryIndicatorSize, height: categoryIndicatorSize)
                    
                    // Инициалы категории
                    Text(getCategoryInitials(category.rawValue))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(category.rawValue)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.headerText)
                
                Spacer()
            }
            .padding(.bottom, 4)
            
            // Список целей
            VStack(spacing: 12) {
                ForEach(targets) { target in
                    HStack(spacing: 12) {
                        // Индикатор цели
                        ZStack {
                            Circle()
                                .fill(category.color.opacity(0.15))
                                .frame(width: targetIndicatorSize, height: targetIndicatorSize)
                            
                            // Прогресс-кольцо
                            Circle()
                                .trim(from: 0, to: CGFloat((target.percentage ?? 0) / 100))
                                .stroke(category.color, lineWidth: 2)
                                .frame(width: targetIndicatorSize - 4, height: targetIndicatorSize - 4)
                                .rotationEffect(.degrees(-90))
                            
                            // Иконка цели
                            Image(systemName: getTargetIcon(for: target))
                                .font(.system(size: 12))
                                .foregroundColor(category.color)
                        }
                        
                        // Основной контент цели
                        TargetRowView<TargetsViewModel>(myTarget: myTarget,
                                                      target: target)
                    }
                    .swipeActions(edge: .trailing) {
                        if myTarget {
                            Button(role: .destructive) {
                                viewModel.deleteTarget(target: target)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .onChange(of: targets, {
                print("Изменилась CategorySectionView")
            })
        }
        .padding(.horizontal, 16)
    }
    
    // Получение инициалов категории
    private func getCategoryInitials(_ title: String) -> String {
        let words = title.split(separator: " ")
        if words.count > 1 {
            return String(words[0].first!).uppercased() + String(words[1].first!).uppercased()
        }
        return String(title.prefix(2)).uppercased()
    }
    
    // Получение иконки для цели
    private func getTargetIcon(for target: UserTargetDtoModel) -> String {
        if (target.percentage ?? 0) >= 100 {
            return "checkmark"
        } else if (target.percentage ?? 0) > 0 {
            return "arrow.up.right"
        }
        return "flag"
    }
}

// MARK: - Preview Provider
#Preview {
    CategorySectionView(
        category: .money,
        targets: [
            UserTargetDtoModel(
                id: 1,
                title: "Test Target",
                description: "Description",
                percentage: 75,
                category: .money
            )
        ],
        onEdit: {}
    )
    .environmentObject(TargetsViewModel())
}

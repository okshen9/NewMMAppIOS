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
    private let categoryIndicatorSize: CGFloat = 36
    private let targetIndicatorSize: CGFloat = 28
    private let cornerRadius: CGFloat = 16
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок категории с индикатором
            headerSection()
            .padding(.bottom, 8)
            
            // Список целей
            targetList()

        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(cornerRadius)
    }

    /// Заголовок категории с индикатором
    @ViewBuilder
    func headerSection() -> some View {
        HStack(spacing: 12) {
            // Индикатор категории
            ZStack {
                // Фоновое свечение
                Circle()
                    .fill(category.color.opacity(0.2))
                    .frame(width: categoryIndicatorSize + 12, height: categoryIndicatorSize + 12)
                    .blur(radius: 6)

                // Основной круг с градиентом
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                category.color,
                                category.color.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: categoryIndicatorSize, height: categoryIndicatorSize)
                    .shadow(color: category.color.opacity(0.3), radius: 4, x: 0, y: 2)

                // Инициалы категории
                Text(getCategoryInitials(category.rawValue))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(category.rawValue)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.headerText)

                // Добавляем количество целей
                Text("\(targets.count) \(targets.count == 1 ? "цель" : "целей")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }

    /// Список целей
    @ViewBuilder
    func targetList() -> some View {
        VStack(spacing: 16) {
            ForEach(targets) { target in
                VStack {
                    HStack(alignment: .top, spacing: 12) {
                        // Индикатор цели
                        VStack(spacing: 6) {
                            indicatorTargetView(target)
                            if let subTargets = target.subTargets,
                               !subTargets.isEmpty {
                                subTasksLabel(subTargets)
                            }
                        }
                        .offset(.init(width: 0, height: 12))

                        // Основной контент цели
                        TargetRowView<TargetsViewModel>(
                            myTarget: myTarget,
                            target: target
                        )
                    }

                }
                .padding()
                .background(Color(.white))
                .cornerRadius(cornerRadius)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .swipeActions(edge: .trailing) {
                    if myTarget {
                        Button(role: .destructive) {
                            withAnimation {
                                viewModel.deleteTarget(target: target)
                            }
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    func indicatorTargetView(_ target: UserTargetDtoModel) -> some View {
        ZStack {
            Circle()
                .fill(category.color.opacity(0.15))
                .frame(width: targetIndicatorSize, height: targetIndicatorSize)

            // Прогресс-кольцо с градиентом
            Circle()
                .trim(from: 0, to: CGFloat((target.percentage ?? 0) / 100))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            category.color,
                            category.color.opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: targetIndicatorSize - 4, height: targetIndicatorSize - 4)
                .rotationEffect(.degrees(-90))

            // Иконка цели
            Image(systemName: getTargetIcon(for: target))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(category.color)
        }
    }
    
    @ViewBuilder
    private func subTasksLabel(_ subTargets: [UserSubTargetDtoModel]) -> some View {
        let done = subTargets.filter({ $0.targetStatus == .done }).count
        let total = subTargets.count
        
        HStack(spacing: 4) {
            Image(systemName: "checklist")
                .font(.system(size: 8))
            Text("\(done)/\(total)")
                .font(.caption)
        }
        .foregroundColor(.blue)
        .padding(.vertical, 3)
        .padding(.horizontal, 6)
        .background(
            Capsule()
                .fill(Color.blue.opacity(0.1))
        )
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
        guard let status = target.targetStatus else { return "star" }
        
        switch status {
        case .inProgress:
            return "star"
        case .done, .doneExpired:
            return "star.fill"
        case .expired:
            return "exclamationmark.circle"
        default:
            return "star"
        }
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
                subTargets: [.init(id: 1, title: "Subtarget 1"),
                             .init(id: 2, title: "Subtarget 2")],
                category: .money
            )
        ],
        onEdit: {}
    )
    .environmentObject(TargetsViewModel())
}

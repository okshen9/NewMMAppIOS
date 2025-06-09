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
        .padding(.horizontal, 8)
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
                    .font(MMFonts.body)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(category.rawValue)
                    .font(MMFonts.title)
                    .bold()
                    .foregroundColor(.headerText)

                // Добавляем количество целей
                Text("\(targets.count) \(targets.count == 1 ? "цель" : "целей")")
                    .font(MMFonts.subTitle)
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
						TargetRowView<TargetsViewModel>(
							myTarget: myTarget,
							target: target
						)

						
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
//				.contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//				.contextMenu {
//					Button(action: {
////								showCloseTaskDialog = true
//					}, label: {
//						Text((target.targetStatus?.isDone).orFalse ? "Переоткрыть цель" : "Закрыть цель")
//					})
//		
//					Button(action: {
////								isEditing = true
//					}, label: {
//						Text("Изменить цель")
//					})
//		
//					Button(action: {
////								showDeleteTaskDialog = true
//					}, label: {
//						Text("Удалить цель")
//					})
//				}
			}
		}
	}

    // Получение инициалов категории
    private func getCategoryInitials(_ title: String) -> String {
        let words = title.split(separator: " ")
        if words.count > 1 {
            return String(words[0].first!).uppercased() + String(words[1].first!).uppercased()
        }
        return String(title.prefix(2)).uppercased()
    }
}

// MARK: - Preview Provider

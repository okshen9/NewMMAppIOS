//
//  TaskProgress.swift
//  NewMMAppIOS
//
//  Created by artem on 13.04.2025.
//

import Foundation
import SwiftUI

/// Обертка для обеспечения обратной совместимости
/// со старой реализацией кругового индикатора прогресса
struct MultiProgressRingView: View {
    let tasks: [TaskProgress]
    @Binding var selectedCategory: TargetCategory?
    @State private var selectedTask: TaskProgress?
    @State private var pieModels: [PieModel] = []
    
    var body: some View {
        // Используем новый компонент диаграммы
        NewPieDiagram(
            slices: pieModels,
            segmentSpacing: 0.02,
            cornerRadius: 8,
            title: "Выполнение целей",
            showCenterLabel: .constant(true),
            isInteractive: .constant(true),
            currentLevel: .constant(0)
        )
        .onAppear {
            // Конвертируем TaskProgress в PieModel для внутреннего использования
            convertTasksToPieModels()
        }
        .onChange(of: tasks) { 
            convertTasksToPieModels()
        }
    }
    
    /// Конвертирует старую модель данных в новую для использования с NewPieDiagram
    private func convertTasksToPieModels() {
        pieModels = tasks.map { task in
            PieModel(
                totalValue: task.value,
                currentValue: task.progress,
                color: task.color,
                title: task.name
            )
        }
    }
}

// Превью для демонстрации компонента
struct PreviewView: View {
    @State private var selectedCategory: TargetCategory? = nil

    @State private var tasks = [
        TaskProgress(progress: 0.75, color: .blue, name: "Бизнес", value: 0.25),
        TaskProgress(progress: 0.5, color: .green, name: "Личное", value: 0.25),
        TaskProgress(progress: 0.9, color: .orange, name: "Семья", value: 0.25),
        TaskProgress(progress: 0.9, color: .yellow, name: "Здоровье", value: 0.25)
    ]

    var body: some View {
        VStack {
            MultiProgressRingView(tasks: tasks, selectedCategory: $selectedCategory)

            HStack(spacing: 20) {
                Button("Обновить") {
                    withAnimation {
                        tasks.indices.forEach {
                            tasks[$0].progress = min(tasks[$0].progress + 0.1, 1.0)
                        }
                    }
                }

                Button("Сбросить") {
                    withAnimation {
                        tasks.indices.forEach {
                            tasks[$0].progress = 0.0
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 8)
        }
    }
}


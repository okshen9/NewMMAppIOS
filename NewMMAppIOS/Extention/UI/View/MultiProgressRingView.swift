//
//  TaskProgress.swift
//  NewMMAppIOS
//
//  Created by artem on 13.04.2025.
//


import Foundation
import SwiftUI

struct TaskProgress: Identifiable {
    let id = UUID()
    var progress: Double
    var color: Color
    var name: String
    var value: Double
}

struct MultiProgressRingView: View {
    @State var selectetedTask: String = "Не выбранно"
    @Binding var selectedCategory: TargetCategory?

    var tasks: [TaskProgress]
    var lineWidth: CGFloat = 15
    var spacing: CGFloat = 3
    var initialDiameter: CGFloat = 200

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                // Кольца прогресса
                ZStack {
                    ForEach(Array(tasks.enumerated().reversed()), id: \.element.id) { index, task in
                        ZStack {
                            let diameter = initialDiameter - (lineWidth + spacing) * 2 * CGFloat(index)

                            // Фоновое кольцо
                            Circle()
                                .stroke(
                                    task.color.opacity(0.2),
                                    lineWidth: lineWidth
                                )
                                .frame(width: diameter, height: diameter)

                            // Кольцо прогресса
                            Circle()
                                .trim(from: 0, to: task.progress)
                                .stroke(
                                    task.color,
                                    style: StrokeStyle(
                                        lineWidth: lineWidth,
                                        lineCap: .round
                                    )
                                )
                                .rotationEffect(.degrees(-90))
                                .animation(.easeOut, value: task.progress)
                                .frame(width: diameter, height: diameter)

                        }
                        .onTapGesture(perform: {
                            selectedCategory = TargetCategory(rawValue: task.name)
                            selectetedTask = task.name
                        })
                    }
                    centrlView()
                }

                // Легенда
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(tasks) { task in
                        HStack {
                            Circle()
                                .fill(task.color)
                                .frame(width: 16, height: 16)
                            Text(task.name)
                            Spacer()
                            Text("\(Int(task.progress * 100))%")
                                .bold()
                        }
                        .font(.subheadline)
                    }
                }
            }
            .padding(.horizontal, 16)
//            Text(selectetedTask)
        }
    }

    @ViewBuilder
    func centrlView() -> some View {
        let diameter = initialDiameter - (lineWidth + spacing) * 2 * CGFloat(tasks.count)
        Color.white
            .frame(width: diameter, height: diameter)
            .cornerRadius(diameter / 2)
            .onTapGesture(perform: {
                selectedCategory = nil
                selectetedTask = "Не выбранно"
            })
    }
}

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
            MultiProgressRingView(selectedCategory: $selectedCategory, tasks: tasks)

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

#Preview {
    PreviewView()
}

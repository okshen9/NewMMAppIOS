//
//  TaskProgress.swift
//  NewMMAppIOS
//
//  Created by artem on 13.04.2025.
//


import Foundation
import SwiftUI

struct MultiProgressRingView: View {
    let tasks: [TaskProgress]
    @Binding var selectedCategory: TargetCategory?
    @State private var selectedTask: TaskProgress?
    @State private var animatedProgress: [CGFloat] = []
    
    var body: some View {
        VStack(spacing: 20) {
            if tasks.isEmpty {
                Text("Нет целей для отображения")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(height: 200)
            } else {
                ZStack {
                    ForEach(tasks.indices, id: \.self) { index in
                        let task = tasks[index]
                        let scale = 1.0 - CGFloat(index) * 0.15
                        
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [task.color.opacity(0.2), task.color.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 12
                            )
                            .scaleEffect(scale)
                        
                        if index < animatedProgress.count {
                            Circle()
                                .trim(from: 0, to: animatedProgress[index])
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [task.color, task.color.opacity(0.8)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .scaleEffect(scale)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 1.0, dampingFraction: 0.8), value: animatedProgress[index])
                        }
                        
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 200 * scale, height: 200 * scale)
                            .contentShape(Circle())
                            .onTapGesture {
                                withAnimation {
                                    selectedTask = task
                                    selectedCategory = TargetCategory(rawValue: task.name)
                                }
                            }
                    }
                    
                    if let selected = selectedTask {
                        VStack {
                            Text(selected.name)
                                .font(.system(size: 16, weight: .semibold))
                            Text("\(Int(selected.progress * 100))%")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(selected.color)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(height: 200)
            }
            
            if !tasks.isEmpty {
                VStack(spacing: 12) {
                    ForEach(tasks) { task in
                        HStack {
                            Circle()
                                .fill(task.color)
                                .frame(width: 12, height: 12)
                            
                            Text(task.name)
                                .font(.system(size: 14))
                            
                            Spacer()
                            
                            Text("\(Int(task.progress * 100))%")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(task.color)
                        }
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                selectedTask = task
                                selectedCategory = TargetCategory(rawValue: task.name)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            // Инициализируем animatedProgress с нулевыми значениями
            animatedProgress = Array(repeating: 0, count: tasks.count)
            
            // Анимируем прогресс после небольшой задержки
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                    animatedProgress = tasks.map { CGFloat($0.progress) }
                }
            }
        }
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

#Preview {
    PreviewView()
}

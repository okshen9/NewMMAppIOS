//
//  CategoryEditView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

struct CategoryEditView: View {
    let category: UserTarget.Category
    @Binding var targets: [UserTarget] // Binding к списку целей
    @Binding var isPresented: Bool
    
    @State private var isAddingNewTarget: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(targets.filter { $0.category == category }) { target in
                    TargetRowView(target: target)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteTarget(target)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                }
            }
            .navigationTitle(category.rawValue)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAddingNewTarget = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingNewTarget) {
                AddTargetView(category: category) { newTarget in
                    targets.append(newTarget) // Добавляем новую цель в список
                }
            }
        }
    }
    
    // Удаление цели
    private func deleteTarget(_ target: UserTarget) {
        targets.removeAll { $0.id == target.id }
    }
}

//
//  CategoryEditView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

struct CategoryEditView: View {
    let category: TargetCategory
    
    @Binding var targets: [UserTargetDtoModel] // Binding к списку целей
    @Binding var isPresented: Bool
    
    @State private var isAddingNewTarget: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach($targets.filter { $0.category.wrappedValue == category }) { target in
                    TargetRowView(target: target.wrappedValue)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteTarget(target.wrappedValue)
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
    private func deleteTarget(_ target: UserTargetDtoModel) {
        targets.removeAll { $0.id == target.id }
    }
}

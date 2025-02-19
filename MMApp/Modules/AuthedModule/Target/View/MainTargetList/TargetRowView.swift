//
//  TargetRowView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

struct TargetRowView: View {
    @Binding var clusedSubTarget: UserSubTargetDtoModel?
    
    
    let target: UserTargetDtoModel
    @State private var isExpanded: Bool = false
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Заголовок, дата, прогресс-бар
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(target.title.orEmpty)
                        .font(.headline)
                        .foregroundColor(.headerText)
                    Text("Срок выполнения: \((target.deadLineDateTime?.dateFromString ?? Date.now).formatted(date: .abbreviated, time: .shortened))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    ProgressView(value: target.percentage, total: 100)
                        .tint(.mainRed)
                }
                Spacer()
                Button(action: { isEditing = true }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.mainRed)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .sheet(isPresented: $isEditing) {
                    TargetEditView(target: target)
                }
            }
            
            // Подцели
            if isExpanded {
                ForEach(target.subTargets ?? []) { subTarget in
                    SubTargetRowView(clusedSubTarget: $clusedSubTarget, subTarget: subTarget)
                }
            }
            
            // Кнопка "Развернуть/Свернуть"
            Button(action: {
                withAnimation { isExpanded.toggle() }
            }) {
                Text(isExpanded ? "Свернуть" : "Развернуть")
                    .font(.caption)
                    .foregroundColor(.mainRed)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(Rectangle())

        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 2)

    }
}

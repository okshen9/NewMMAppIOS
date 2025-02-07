//
//  SubTargetRowView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

struct SubTargetRowView: View {
    @State private var showConfirmationDialog = false
    @State private var isLoading = false
    @State private var isCompleted = false
    
    let subTarget: UserSubTarget
    
    var body: some View {
        HStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Button(action: { showConfirmationDialog = true }) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? .green : .gray)
                }
                .buttonStyle(.plain)
                .background(
                    ConfirmationDialog(
                        message: "Вы закрыли эту подцель?",
                        onConfirm: {
                            isLoading = true
                            showConfirmationDialog = false
                            completeSubTarget()
                        },
                        onCancel: { showConfirmationDialog = false }
                    )
                    .opacity(showConfirmationDialog ? 1 : 0) // Показываем/скрываем диалог
                )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subTarget.title)
                    .font(.subheadline)
                Text("Дедлайн: \(subTarget.deadLineDateTime.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func completeSubTarget() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
            isCompleted = true
        }
    }
}

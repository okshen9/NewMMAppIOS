//
//  SubTargetRowView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI
import Combine

struct SubTargetRowView: View {
    
    
    @Binding var clusedSubTarget: UserSubTargetDtoModel?
    
    @State private var showConfirmationDialog = false
    @State private var isLoading = false
    
    let subTarget: UserSubTargetDtoModel
    
    var body: some View {
        HStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Button(action: {
                    if subTarget.targetStatus != .done {
                        isLoading = true
                        clusedSubTarget = subTarget
                    }
                    
//                    isLoading = true
//                    
//                    completeSubTarget()
                    
                }) {
                    Image(systemName: subTarget.targetStatus == .done ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(subTarget.targetStatus == .done ? .green : .gray)
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
                Text(subTarget.title.orEmpty)
                    .font(.subheadline)
                Text("Срок выполнения: \((subTarget.deadLineDateTime?.dateFromString ?? Date.now).formatted(date: .abbreviated, time: .shortened))")
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
        }
    }
}

//#Preview {
//    SubTargetRowView(subTarget: UserSubTarget.init(id: 0, title: "ssf", description: "sfsdf", subTargetPercentage: 13, targetStatus: "sdfsdf", rootTargetId: 12312, isDeleted: false, creationDateTime: Date.now, lastUpdatingDateTime: Date.now, deadLineDateTime: Date.now))
//}

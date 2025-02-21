//
//  SubTargetRowView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI
import Combine

//if subTarget.targetStatus != .done {
//    isLoading = true
//    clusedSubTarget = subTarget
//}


struct SubTargetRowView: View {
    
    
    @Binding var clusedSubTarget: UserSubTargetDtoModel?
    
    @State private var showConfirmationDialog = false
    @State private var isLoading = false
    
    @Binding var subTarget: UserSubTargetDtoModel
    
    var body: some View {
        HStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                closeButton()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subTarget.title.orEmpty)
                    .font(.headline)
                    .foregroundColor(.headerText)
                Text("Срок выполнения: \((subTarget.deadLineDateTime?.dateFromString ?? Date.now).formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .onChange(of: subTarget, {
            print("Изменилась subTarget")
            isLoading = false
        })
    }
    
    @ViewBuilder
    func closeButton() -> some View {
        Button(action: {
                showConfirmationDialog = true
        }) {
            Image(systemName: $subTarget.targetStatus.wrappedValue == .done ? "checkmark.circle.fill" : "circle")
                .foregroundColor($subTarget.targetStatus.wrappedValue == .done ? .green : .gray)
        }
        .buttonStyle(.plain)
        .alert(isPresented: $showConfirmationDialog,
               content: {
            let title = (subTarget.targetStatus?.isDone) ?? false ? "Вы хотите открыть цель?" : "Вы закрыли цель?"
            return Alert(title: Text(title),
                  primaryButton:
                    .default(Text("Да"), action: {
                        //                        subTarget.targetStatus = .done
                        isLoading = true
                        clusedSubTarget = subTarget
                        print("Done")
                    }),
                  secondaryButton:
                    .destructive(Text("Нет"), action: {
                        //                        subTarget.targetStatus = .inProgress
                        print("Not Done")
                    })
            )
        })
    }
}

//#Preview {
//    SubTargetRowView(subTarget: UserSubTarget.init(id: 0, title: "ssf", description: "sfsdf", subTargetPercentage: 13, targetStatus: "sdfsdf", rootTargetId: 12312, isDeleted: false, creationDateTime: Date.now, lastUpdatingDateTime: Date.now, deadLineDateTime: Date.now))
//}

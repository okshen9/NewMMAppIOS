//
//  SubTargetEditView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

struct SubTargetEditView: View {
    
    @Binding var subTarget: UserSubTargetDtoModel
    
    var body: some View {
        
        VStack(spacing: 8) {
            TextField("Название", text: $subTarget.title.orEmptyBinding)
                .foregroundStyle(Color.headerText)
            TextEditorWithPalceHolder(palceHolder: "Описание", textBinding: $subTarget.description.orEmptyBinding)
            DatePicker("Срок выполнения", selection: $subTarget.deadLineDateTime.asBindingDate, displayedComponents: .date)
                .tint(Color.mainRed)
        }
    }
}

#Preview {
    SubTargetEditView(subTarget: .constant(.init()))
}

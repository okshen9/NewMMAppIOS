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
        
        VStack {
            TextField("Название", text: $subTarget.title.orEmptyBinding)
                .foregroundStyle(Color.black.opacity(0.8))
            TextField("Описание", text: $subTarget.description.orEmptyBinding)
                .foregroundStyle(Color.black.opacity(0.8))
            DatePicker("Срок выполнения", selection: $subTarget.deadLineDateTime.asDate, displayedComponents: .date)
                .tint(Color.mainRed)
        }
    }
}

#Preview {
    SubTargetEditView(subTarget: .constant(.init()))
}

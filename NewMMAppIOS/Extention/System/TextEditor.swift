//
//  TextEditor.swift
//  NewMMAppIOS
//
//  Created by artem on 27.04.2025.
//

import SwiftUI

struct TextEditorWithPalceHolder: View {
    let palceHolder: String
    @Binding var textBinding: String
    
    var body: some View {
            ZStack(alignment: .topLeading) {
                if $textBinding.wrappedValue.isEmpty {
                    Text(palceHolder)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
                TextEditor(text: $textBinding)
                    .padding(.leading, -4)
                    .frame(maxHeight: 200)
            }
    }
}

#Preview {
    @Previewable @State var text: String = "sdfsdf"
    TextEditorWithPalceHolder(palceHolder: "sdds", textBinding: $text)
}

#Preview {
    Group {
        TargetEditView<TargetsViewModel>(target: .init(title: "Test",
                                                   targetStatus: .inProgress,
                                                   subTargets: [.init(title: "TestSub", targetSubStatus: .notDone, creationDateTime: Date.now.toApiString)]
                                                  ), isCreateTarget: false)
            .environmentObject(TargetsViewModel())
    }
}

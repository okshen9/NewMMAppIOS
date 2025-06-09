//
//  ChekMarView.swift
//  NewMMAppIOS
//
//  Created by artem on 13.04.2025.
//

import SwiftUI

struct ChekMarkView: View {
    init(_ checked: Binding<Bool>) {
        self._checked = checked
    }

    @Binding var checked: Bool
    var body: some View {
        Image(systemName: checked ? "checkmark.circle.fill" : "circle")
            .foregroundColor(checked ? .green : .gray)
    }
}


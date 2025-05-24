//
//  ValidatedTextEditor.swift
//  MMApp
//
//  Created by artem on 24.03.2025.
//

import SwiftUI

/// Многострочное поле ввода
struct ValidatedTextEditor: View {
    let title: String
    @Binding var text: String
    let error: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(MMFonts.title)
                .foregroundColor(Color.headerText)
            TextEditor(text: $text)
                .foregroundColor(Color.headerText)
                .frame(height: 100)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            if let error = error {
                Text(error)
                    .foregroundColor(.headerText)
                    .font(MMFonts.caption)
					.foregroundStyle(Color.mainRed)
            }
        }
    }
}

#Preview {
    @Previewable @State var text = "wed"
    ValidatedTextEditor(title: "test", text: $text, error: "error")
}

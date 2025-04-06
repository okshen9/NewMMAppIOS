//
//  ValidatedTextEditor.swift
//  MMApp
//
//  Created by artem on 24.03.2025.
//

import SwiftUI

struct ValidatedTextEditor: View {
    let title: String
    @Binding var text: String
    let error: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            TextEditor(text: $text)
                .frame(height: 100)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    ValidatedTextEditor(title: "test", text: .constant(""), error: "error")
}

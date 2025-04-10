//
//  ValidatedTextField.swift
//  MMApp
//
//  Created by artem on 24.03.2025.
//

import SwiftUI

struct ValidatedTextField: View {
    let title: String
    @Binding var text: String
    let error: String?
    private var canEdit: Bool // Добавляем параметр для управления редактированием

    // Инициализатор с параметром canEdit
    init(title: String, text: Binding<String>, error: String?, canEdit: Bool = true) {
        self.title = title
        self._text = text
        self.error = error
        self.canEdit = canEdit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            TextField("", text: $text)
                .textFieldStyle(.roundedBorder)
                .disabled(!canEdit) // Блокировка поля
            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }

    // Модификатор для изменения canEdit
    func setCanEdit(_ canEdit: Bool) -> some View {
        ValidatedTextField(
            title: title,
            text: $text,
            error: error,
            canEdit: canEdit
        )
    }
}

#Preview {
    ScrollView {
        VStack {
            ValidatedTextField(title: "test", text: .constant(""), error: "error")
            ValidatedTextField(title: "test", text: .constant(""), error: "error")
        }
    }
}

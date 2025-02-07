//
//  CategorySectionView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

struct CategorySectionView: View {
    let category: UserTarget.Category
    let targets: [UserTarget] // Список целей для выбранной категории
    var onEdit: () -> Void // Замыкание для редактирования категории

    var body: some View {
        Section(header:
            HStack {
                Text(category.rawValue)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.headerText)
                Spacer()
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.mainRed)
                }
            }
        ) {
            ForEach(targets) { target in
                TargetRowView(target: target)
            }
        }
    }
}

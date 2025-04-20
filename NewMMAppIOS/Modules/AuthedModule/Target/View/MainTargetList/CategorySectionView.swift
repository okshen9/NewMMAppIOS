//
//  CategorySectionView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

struct CategorySectionView: View {
    let myTarget = true
    var category: TargetCategory
    var targets: [UserTargetDtoModel] // Список целей для выбранной категории
    @State var onEdit: () -> Void // Замыкание для редактирования категории

    var body: some View {
        Section(header:
            HStack {
                Text(category.rawValue)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.headerText)
                Spacer()
            }
        ) {
            ForEach(targets) { target in
                TargetRowView<TargetsViewModel>(target: target)
            }
            .onChange(of: targets, {
                print("Изменилась CategorySectionView")
            })
        }

    }

}

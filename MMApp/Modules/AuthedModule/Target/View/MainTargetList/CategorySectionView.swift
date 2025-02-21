//
//  CategorySectionView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

struct CategorySectionView: View {
    @Binding var clusedSubTarget: UserSubTargetDtoModel?
    @Binding var clusedTarget: UserTargetDtoModel?
    
    
    @State var category: TargetCategory
    @Binding var targets: [UserTargetDtoModel] // Список целей для выбранной категории
    @State var onEdit: () -> Void // Замыкание для редактирования категории

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
            ForEach($targets) { target in
                TargetRowView(clusedSubTarget: $clusedSubTarget, clusedTarget: $clusedTarget, target: target)
            }
            .onChange(of: targets, {
                print("Изменилась CategorySectionView")
            })
        }

    }

}

//extension Array: Equatable where Element == UserTargetDtoModel {
//    static func == (lhs: Self, rhs: Self) -> Bool {
//        
//    }
//}

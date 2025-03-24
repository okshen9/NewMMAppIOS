//
//  FeedCell.swift
//  MMApp
//
//  Created by artem on 19.03.2025.
//

import SwiftUI

struct FeedCell: View {
    let type: FeedCellType
    let title: String
    let subtitle: String
    let date: String
//    let event: EventDTO
    
    var body: some View {
        VStack {
            Text("title: " + title)
                .font(.headline)
            Text("subtitle: " + subtitle)
                .font(.subheadline)
            Text("Date: " + (date.dateFromString?.toDisplayString ?? "sds"))
        }
        .padding()
        .background(Color.secondbackGraund)
        .cornerRadius(8)
    }
}

#Preview {
    FeedCell(type: .payment, title: "Петр закрыл цель", subtitle: "Цель Выпить пива", date: "\(Date().toApiString)")
}

enum FeedCellType {
    case task
    case payment
}

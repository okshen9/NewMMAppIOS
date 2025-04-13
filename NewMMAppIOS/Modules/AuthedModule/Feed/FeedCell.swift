//
//  FeedCell.swift
//  MMApp
//
//  Created by artem on 19.03.2025.
//

import Kingfisher
import SwiftUI

struct FeedCell: View {
    let type: FeedCellType
    let title: String
    let subtitle: String
    let date: String
    let userProfile: UserProfileResultDto?
    let eventType: EventType?
    //    let event: EventDTO

    var body: some View {
        VStack(alignment: .leading) {

            avatarHeader()
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.headerText)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Color.headerText)
            Text((date.dateFromString?.toDisplayString ?? ""))
                .foregroundStyle(Color.headerText)
        }
        //        .frame(width: .infinity)
        .padding()
        .frame(width: 370, alignment: .leading)


        //        .padding()
        .background(Color.secondbackGraund)

        .cornerRadius(8)

        //        .padding()  // Сначала задайте отступы
        //        .frame(width: .infinity)
    }



        @ViewBuilder
        func avatarHeader() -> some View {
            HStack {
                KFImage(URL(string: (userProfile?.photoUrl).orEmpty))
                    .placeholder {
                        Image(.MM)
                            .resizable(resizingMode: .stretch)
                            .renderingMode(.template)
                            .padding(6)

                    }
                    .resizable(resizingMode: .stretch)
                    .frame(width: 30, height: 30)
                    .cornerRadius(20)
                    .clipShape(Circle())
                    .overlay {
                        Circle().stroke(.gray, lineWidth: 1)
                    }
                Text(userProfile?.fullName ?? "Неизвестный пользователь")
                    .font(.headline)
                    .foregroundStyle(.black)
                Text(eventType?.name ?? .empty)

            }
        }
}

#Preview {
    FeedCell(type: .payment, title: "Петр закрыл цель", subtitle: "Цель Выпить пива", date: "\(Date().toApiString)",
             userProfile: .init(
                id: nil,
                externalId: nil,
                username: nil,
                fullName: "BVz gjgjg",
                userProfileStatus: nil,
                userPaymentStatus: nil,
                isDeleted: nil,
                creationDateTime: nil,
                lastUpdatingDateTime: nil,
                userGroups: nil,
                stream: nil,
                comment: nil,
                photoUrl: "https://t.me/i/userpic/320/JSquw0AMRhjD23aa7jeO88wyDYFr03Z4CeAktb-q7BM.jpg",
                userTargets: nil,
                targetCalculationInfo: nil,
                location: nil,
                phoneNumber: nil,
                activitySphere: nil,
                paymentCalculationInfo: nil,
                biography: nil),
             eventType: .TARGET_DONE)
}

enum FeedCellType {
    case task
    case payment
}

//
//  TargetCell.swift
//  NewMMAppIOS
//
//  Created by artem on 12.04.2025.
//

import SwiftUI
import Kingfisher

protocol BasicEventCell: View {
    var event: EventDTO { get set }
}

extension BasicEventCell {
    @ViewBuilder
    @MainActor
    func headerEvent() -> some View {
        HStack(alignment: .center) {
            KFImage(URL(string: (event.userProfile?.photoUrl).orEmpty))
                .placeholder {
                    Image(.MM)
                        .resizable(resizingMode: .stretch)
                        .renderingMode(.template)
                        .padding(6)

                }
                .resizable(resizingMode: .stretch)
                .cornerRadius(22)
                .overlay {
                    Circle().stroke(Color.mainRed, lineWidth: 1)
                }
                .frame(width: 32, height: 32)
            VStack(alignment: .leading) {
                Text((event.userProfile?.fullName) ?? "Пользователь без имени")
                    .foregroundStyle(Color.headerText)
                    .font(.body.bold())
                    .frame(alignment: .leading)

                Text((event.type?.feedActionName).orEmpty)
                    .foregroundStyle(Color.headerText)
                    .font(.body.bold())
                    .frame(alignment: .leading)
            }
            Spacer()
            IconActionFeedView(type: event.type ?? .unknown)
        }
    }

    @ViewBuilder
    @MainActor
    func bottomDate() -> some View {
        HStack {
            Spacer()
            let displayString = event.displayDate?.dateFromString?.toDisplayString ?? Date().toDisplayString
            Text(displayString)
                .font(.body)
                .foregroundStyle(Color.headerText)
        }
    }

}

struct NewFeedCell: BasicEventCell {
    var onHeaderTap: () -> Void
    var event: EventDTO
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerEvent()
                .padding(.bottom, 8)
                .onTapGesture {
                    onHeaderTap()
                }
            bodyEvent()
            bottomDate()
        }
        .padding()
        .background(.white)
        .cornerRadius(26)

        .shadow(color: .gray, radius: 4)
//        .frame(width: .infinity)
    }

    @ViewBuilder
    @MainActor
    func bodyEvent() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.title ?? "Описание не указано")
                .foregroundStyle(Color.headerText)
                .font(.body.bold())
                .multilineTextAlignment(.leading)


            Text(event.description ?? "Описание не указано")
                .foregroundStyle(Color.subtitleText)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
        }
    }




}

#Preview {
    NewFeedCell(onHeaderTap: {}, event: .getTextEvent(for: .TARGET_DONE))
        .padding(.horizontal, 8)
}

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

struct NewFeedCell: BasicEventCell {
    var onHeaderTap: () -> Void
    var onHideUser: ((Int) async -> Bool)
    var showHidenTogle: Bool {
        event.creatorExternalId != UserRepository.shared.externalId?.toString
    }
    @State var isLoading = false
    @State private var showHideUserAlert = false
    @State private var userToHide: (externalId: Int, name: String)?
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
        .alert("Скрыть пользователя", isPresented: $showHideUserAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Скрыть", role: .destructive) {
                
                if let externalId = Int(event.creatorExternalId.orEmpty) {
                    Task {
                        isLoading = true
                        await onHideUser(externalId)
                        isLoading = false
                    }
                }
            }
        } message: {
            Text("Вы уверены, что хотите скрыть все новости от пользователя \(event.userProfile?.fullName ?? "Неизвестный пользователь")?")
        }
    }

    @ViewBuilder
    @MainActor
    func bodyEvent() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.title ?? "Описание не указано")
                .foregroundStyle(Color.headerText)
                .font(MMFonts.body)
                .multilineTextAlignment(.leading)


            Text(event.description ?? "Описание не указано")
                .foregroundStyle(Color.subtitleText)
                .font(MMFonts.subTitle)
                .multilineTextAlignment(.leading)
        }
    }
    
    // MARK: - Basic Event
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
                    .font(MMFonts.body)
                    .frame(alignment: .leading)

                Text((event.type?.feedActionName).orEmpty)
                    .foregroundStyle(Color.headerText)
                    .font(MMFonts.body)
                    .frame(alignment: .leading)
            }
            Spacer()
            if showHidenTogle {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                } else {
                    Menu {
                        Button(action: {
                            showHideUserAlert = true
                        }) {
                            Label("Скрыть контент пользователя", systemImage: "eye.slash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                            .padding(8)
                    }
                }
            }
            
            IconActionFeedView(type: event.type ?? .unknown)
        }
    }

    @ViewBuilder
    @MainActor
    func bottomDate() -> some View {
        HStack {
            Spacer()
            let displayString = event.displayDate?.dateFromApiString?.toDisplayString ?? Date().toDisplayString
            Text(displayString)
                .font(MMFonts.body)
                .foregroundStyle(Color.headerText)
        }
    }
}


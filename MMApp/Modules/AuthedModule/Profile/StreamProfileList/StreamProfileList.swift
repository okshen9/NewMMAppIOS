//
//  ProfileListView.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

import SwiftUI
// MARK: - View

struct StreamProfileList: View {
    let type: TypeGroupe
    let status: StatusGruop
    let mentors: [StreamUserProfileShortInfoDto]
    let participants: [StreamUserProfileShortInfoDto]
    var dateStart: Date = Date.init(timeIntervalSince1970: 232324)
    var dateEnd: Date = Date.now
    
    var body: some View {
            VStack {
                HStack {
                    let dateStr1 = DateFormatter.localizedString(from: dateStart, dateStyle: .short, timeStyle: .none)
                    let dateStr2 = DateFormatter.localizedString(from: dateEnd, dateStyle: .short, timeStyle: .none)
                    Text(dateStr1 + " - " + dateStr2)
                        .font(.body)
                        .bold()
                    Spacer()
                    Text(status.name)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(status.color)
                        .cornerRadius(8)
                }
                .padding()
                
                List {
                    if !mentors.isEmpty {
                        Section(header: Text("Менторы").font(.headline)) {
                            ForEach(mentors) { mentor in
                                UserRow(user: mentor)
                            }
                        }
                    }
                    
                    if !participants.isEmpty {
                        Section(header: Text("Участники").font(.headline)) {
                            ForEach(participants) { participant in
                                UserRow(user: participant)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle(type.name)
        }
}

#Preview {
    StreamProfileList(type: .stream("7"), status: .ended,
              mentors: mockOwners,
              participants: mockParticipants)
}

// MARK: - UserRow

struct UserRow: View {
    let user: StreamUserProfileShortInfoDto
    
    var body: some View {
        let viewModel = ProfileViewModel(externalId: user.externalId)
        NavigationLink(destination: ProfileView(viewModel: viewModel)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(user.fullName ?? "Неизвестный пользователь")
                        .font(.body)
                        .foregroundColor(.headerText)
                        .bold()
                    if let username = user.username {
                        Text(username)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                if let progress = user.targetCalculationInfoDto?.allCategoriesDonePercentage {
                    ProgressView(value: progress, total: 100)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(width: 50)
                }
            }
            .padding(4)
        }
    }
}

// MARK: - UserProfileView (Заглушка)

enum TypeGroupe {
    case stream(String)
    case group(String)
    
    var name: String {
        switch self {
        case .stream(let name): return "Стрим " + name
        case .group(let name): return "Группа " + name
        }
    }
}

enum StatusGruop {
    case ended
    case current
    
    var name: String {
        switch self {
        case .ended: return "Завершен"
        case .current: return "Текущий"
        }
    }
    
    var color: Color {
        switch self {
        case .ended: return .red
        case .current: return .green
        }
    }
}


let mockOwners: [StreamUserProfileShortInfoDto] = [
    StreamUserProfileShortInfoDto(
        externalId: 14,
        username: "katesapon",
        fullName: "Сапон Екатерина Игоревна",
        targetCalculationInfoDto: nil
    )
]

let mockParticipants: [StreamUserProfileShortInfoDto] = [
    StreamUserProfileShortInfoDto(
        externalId: 11,
        username: "okshen9",
        fullName: "Artem Neshko",
        targetCalculationInfoDto: nil
    ),
    StreamUserProfileShortInfoDto(
        externalId: 12,
        username: "KirillMoiseenkov",
        fullName: "Kirill Moiseenkov",
        targetCalculationInfoDto: nil
    ),
    StreamUserProfileShortInfoDto(
        externalId: 9,
        username: "bestofoleg",
        fullName: "Oleg Abramov",
        targetCalculationInfoDto: nil
    )
]

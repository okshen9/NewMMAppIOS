//
//  HiddenProfileCell.swift
//  NewMMAppIOS
//
//  Created by artem on 01.06.25.
//

import SwiftUI


struct HiddenProfileCell: View {
    let profile: UserProfileResultDto
    let onUnhide: () -> Void
    let openTelegramChat: (String) -> Void
    @State private var isUnhiding = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Аватар
            CircleImagView(photoUrl: URL(string: profile.photoUrl.orEmpty))
                .frame(width: 50, height: 50)
            
            // Информация о пользователе
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.fullName ?? "Неизвестный пользователь")
                    .font(MMFonts.body)
                    .foregroundColor(.headerText)
                    .lineLimit(1)
                
                if let location = profile.location {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(location)
                            .font(MMFonts.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
                if let username = profile.username {
                    Text("@\(username)")
                        .font(MMFonts.caption)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                        .onTapGesture {
                            guard let username = profile.username else { return }
                            openTelegramChat(username)
                        }
                }
            }
            
            Spacer()
            
            // Кнопка разблокировки
            Button(action: {
                if !isUnhiding {
                    isUnhiding = true
                    onUnhide()
                    
                    // Сброс состояния через 2 секунды на случай ошибки
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isUnhiding = false
                    }
                }
            }) {
                VStack(spacing: 4) {
                        Image(systemName: "eye")
                            .font(.body)
                        Text("Разблокировать")
                            .font(MMFonts.subCaption)
                            .foregroundStyle(.white)
                            .lineLimit(1)

                }
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
                .background(Color.mainRed)
                .cornerRadius(16)

            }
            .disabled(isUnhiding)
            .overlay {
                if isUnhiding {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    HiddenProfileCell(profile: .getTestUser(), onUnhide: {}, openTelegramChat: {tt in })
//    Text("s")
}


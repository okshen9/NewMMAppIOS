//
//  GroupUserRow.swift
//  NewMMAppIOS
//
//  Created by artem on 07.06.25.
//

import SwiftUI

struct GroupUserRow: View {
    let user: UserProfileResultDto
    
    var body: some View {
        NavigationLink(destination: ProfileView(externalId: user.externalId)) {
            HStack(spacing: 12) {
                CircleImagView(photoUrl: URL(string: user.photoUrl.orEmpty))
                    .frameRect(50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.fullName ?? "Неизвестный пользователь")
                        .font(MMFonts.body)
                        .foregroundColor(.headerText)
                        .bold()
                    
                    if let username = user.username {
                        Text("@\(username)")
                            .font(MMFonts.subTitle)
                            .foregroundColor(.gray)
                    }
                    
                    if let location = user.location {
                        Text(location)
                            .font(MMFonts.subTitle)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
//                
//                if let progress = user.targetCalculationInfo?.allCategoriesDonePercentage {
//                    VStack(spacing: 4) {
//                        Text("\(Int(progress))%")
//                            .font(MMFonts.subTitle)
//                            .foregroundColor(.headerText)
//                        
//                        ProgressView(value: progress, total: 100)
//                            .progressViewStyle(LinearProgressViewStyle())
//                            .frame(width: 60)
//                    }
//                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

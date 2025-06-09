//
//  CircleImagView.swift
//  MMApp
//
//  Created by artem on 04.03.2025.
//
import Kingfisher
import SwiftUI

struct CircleImagView: View {
    var photoUrl: URL?
    
    var body: some View {
        VStack {
            if let photoUrl {
                KFImage(photoUrl)
                    .placeholder { getPlaceHolder() }
                    .resizable(resizingMode: .stretch)
                    .cancelOnDisappear(true)
                    .backgroundDecode()
                    .scaleFactor(UIScreen.main.scale)
                    .cacheOriginalImage()
//                    .downsampling(size: CGSize(width: Constraint.width, height: Constraint.height))
                
            } else {
                Image(.MM)
                    .resizable(resizingMode: .stretch)
                    .renderingMode(.template)
                    .padding(40)
                    .foregroundStyle(Color.gray)
                    .background(Color.white)
            }
        }
        .clipShape(Circle())
//        .frame(width: Constraint.width, height: Constraint.height)
        .overlay {
            Circle().stroke(.gray, lineWidth: 4)
        }
        .shadow(radius: 7)
    }
    
    @ViewBuilder
    func getPlaceHolder() -> some View {
        Image(.MM)
            .resizable(resizingMode: .stretch)
            .renderingMode(.template)
            .padding(10)
            .foregroundStyle(Color.gray)
            .background(Color.white)
    }
}


extension CircleImagView {
    enum Constraint {
        static let height: CGFloat = 150
        static let width: CGFloat = 150
    }
}


#Preview {
    HiddenProfileCell(profile: .getTestUser(), onUnhide: {}, openTelegramChat: {tt in })
//    Text("s")
}

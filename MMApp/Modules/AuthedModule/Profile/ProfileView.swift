import SwiftUI
import Kingfisher

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    let index: Int
//    var user: AuthUserDtoResult
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            KFImage(Constants.imageUrl)
                .resizable()
                .placeholder { Color.gray }
                .cancelOnDisappear(true)
                .backgroundDecode()
                .scaleFactor(UIScreen.main.scale)
                .cacheOriginalImage()
                .downsampling(size: CGSize(width: 88, height: 88))
                .clipShape(Circle())
                .frame(width: 88, height: 88)
            
            HStack {
                Text("Имя ")
                    .foregroundColor(.subtitleText)
                Text("Артем")
                    .foregroundColor(.headerText)
            }
            .padding(8)
            .background(Color.secondbackGraund)
            .cornerRadius(8)
            
            HStack {
                Text("Фамилия ")
                    .foregroundColor(.subtitleText)
                Text("Нешко")
                    .foregroundColor(.headerText)
            }
            .padding(8)
            .background(Color.secondbackGraund)
            .cornerRadius(8)
            
            HStack {
                Text("Телеграмм: ")
                    .foregroundColor(.subtitleText)
                Text("@okshen9")
                    .foregroundColor(.headerText)
            }
            .padding(8)
            .background(Color.secondbackGraund)
            .cornerRadius(8)

            HStack {
                Text("Род деятельности: ")
                    .foregroundColor(.subtitleText)
                Text("Продаю на Wb")
                    .foregroundColor(.headerText)
            }
            .padding(8)
            .background(Color.secondbackGraund)
            .cornerRadius(8)
            
            HStack {
                Text("Учавствовал в: ")
                    .foregroundColor(.subtitleText)
                Text("7 поток")
                    .foregroundColor(.headerText)
            }
            .padding(8)
            .background(Color.secondbackGraund)
            .cornerRadius(8)
            
            HStack {
                Text("Стутус завершения ")
                    .foregroundColor(.subtitleText)
                Text("Закончил")
                    .foregroundColor(.headerText)
            }
            .padding(8)
            .background(Color.secondbackGraund)
            .cornerRadius(8)
            Spacer()
        }
        .padding(.top, 16)
        
    }
}

// MARK: - Constants
extension ProfileView {
    private enum Constants {
        static let title = "Выберите карту"
        static let imageUrl = URL(string: "https://t.me/i/userpic/320/yrCHD_HRHDVktpQhLHeDQ6TsYP-1SgldytAKXBHlux0.jpg")
    }
}

#Preview {
    ProfileView(index: 2)
}

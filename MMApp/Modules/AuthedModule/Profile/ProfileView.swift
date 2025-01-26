import SwiftUI
import Kingfisher

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    let index: Int
//    var user: AuthUserDtoResult
    var body: some View {
        VStack(alignment: .leading) {
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
            Text("Артем")
                .foregroundColor(.headerText)
            Text("Нешко")
                .foregroundColor(.headerText)
            Text("Продаю на Wb")
                .foregroundColor(.headerText)
            Button("Update") {
                viewModel.updateTitle()
            }
            .foregroundColor(.green)
        }
        
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

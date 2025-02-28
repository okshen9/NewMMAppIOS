import SwiftUI
import Kingfisher

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.profile == nil || $viewModel.isLoading.wrappedValue  {
                    shimerState()
                } else {
                    contentState()
                }
            }
            .onAppear {
                viewModel.onApper()
            }
        }
    }
    
    
    @ViewBuilder
    func contentState() -> some View {
        if let profile = viewModel.profile {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center) {
                    Spacer()
                    VStack {
                        if let urlStr = profile.photoUrl,
                           let photoUrl = URL(string: urlStr) {
                            KFImage(photoUrl)
                                .placeholder { Image(.profile)
                                    .resizable(resizingMode: .stretch)}
                                .resizable(resizingMode: .stretch)
                                .cancelOnDisappear(true)
                                .backgroundDecode()
                                .scaleFactor(UIScreen.main.scale)
                                .cacheOriginalImage()
                                .downsampling(size: CGSize(width: 88, height: 88))
                                .clipShape(Circle())
                                .frame(width: 88, height: 88)
                            
                        } else {
                            Image(.profile)
                                .clipShape(Circle())
                                .frame(width: 88, height: 88)
                        }
                        Text(profile.fullName ?? "Имя не указано")
                            .font(.headline)
                            .foregroundColor(.headerText)
                    }
                    Spacer()
                }
                
                HStack(spacing: 8) {
                    let streamStatus = profile.stream?.title != nil ?
                    profile.stream?.isActive ?? false ? "Текущий" : "Завершен" :
                    nil
                    
                    NavigationLink(destination: {
                        if let stream = profile.stream,
                           let owners = stream.owners,
                           let participants = stream.participants
                        {
                            
                            StreamProfileList(
                                type: .stream(stream.title ?? "Поток без названия"),
                                status: stream.isActive ? .current : .ended,
                                mentors: owners,
                                participants: participants,
                                dateStart: (profile.stream?.dateFrom?.dateFromStringISO8601) ?? Date.init(timeIntervalSince1970: 232),
                                dateEnd: (profile.stream?.dateTo?.dateFromStringISO8601) ?? Date.now
                            )
                        } else {
                            Text("Error")
                        }
                    }, label: {
                        GroupButton(
                            title: profile.stream?.title ?? "Поток не назначен",
                            subTitle: streamStatus,
                            action: {})
                    })
                    
                    
//                    GroupButton(title: profile.stream?.title ?? "Поток не назначен",
//                                subTitle: streamStatus,
//                                action: {})
                    GroupButton(title: profile.userGroup?.title ?? "Подгруппа",
                                subTitle: (profile.userGroup?.title).isNil ? "Не названчена" : nil,
                                action: {})
                }
                .frame(height: 56)
                
                
                descriptionView("Специазируюсь: ", profile.activitySphere ?? "-")
                descriptionView("Город: ", profile.location ?? "не указано")
                HStack {
                    Text("Telegram:")
                    Button (action: {
                        //GOTO Telegram
                        guard let username = profile.username else { return }
                        viewModel.openTelegramChat(username: username)
                    }, label: {
                        HStack {
                            Text("@\(profile.username ?? "exampleName")")
                                .foregroundColor(.headerText)
                            Image(.tg)
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                    })
                }
            }
            .padding(16)
            Spacer()
        } else {
            ShimmeringRectangle()
                .frame(width: 88, height: 88)
                .cornerRadius(44)
            Spacer()
        }
    }
    
    @ViewBuilder
    func descriptionView(_ key: String, _ value: String) -> some View {
        HStack() {
            Text(key)
                .font(.subheadline)
                .foregroundColor(.subtitleText)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.headerText)
        }
    }
    
    
    @ViewBuilder
    func shimerState() -> some View {
        VStack(spacing: 20) {
            ShimmeringRectangle()
                .frame(width: 88, height: 88)
                .cornerRadius(44)
            
            ShimmeringRectangle()
                .frame(height: 20)
                .cornerRadius(8)
            
            ShimmeringRectangle()
                .frame(height: 20)
                .cornerRadius(8)
                .padding(.horizontal, 40)
            
            ShimmeringRectangle()
                .frame(height: 40)
                .cornerRadius(8)
                .padding(.top, 20)
            Spacer()
        }
        .padding(.horizontal, 16)
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
    ProfileView()
}

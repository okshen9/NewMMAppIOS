import SwiftUI
import Kingfisher
//import Yamobaile

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    @State var showMap = false

    var body: some View {
        NavigationStack {
            
            VStack {
                if viewModel.profile == nil || $viewModel.isLoading.wrappedValue  {
                    shimerState()
                } else {
                    contentState()
                        
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                viewModel.onApper()
            }
            .ignoresSafeArea(edges: .top)
        }
    }
    
    
    @ViewBuilder
    func contentState() -> some View {
        if let profile = viewModel.profile {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    MapView(viewModel:
                            .init(nameCity: viewModel.profile?.location ?? "Москва",
                                  nameUser: viewModel.profile?.fullName ?? "Пользователь без имени"))
                    .padding(.horizontal, -16)
                    .frame(height: showMap ? 800 : 230)
                    .cornerRadius(20)
                    .onTapGesture {
                        /// TODO - добавить интерактивность карты
//                        showMap.toggle()
                    }
                    
                    // Аватарка
                    HStack(alignment: .bottom) {
                        
                        Spacer()
//                        ProfileStatsView(progress: 0.5, title: "Вовлек: 2/4")
////                            .padding(.trailing, 30)
//                            .padding(.bottom, 50)
                        VStack(spacing: 10) {
                            HStack(spacing: 25) {
                                ProfileStatsView(progress: 0.5, title: "Вовлек: 2/4")
                                    .frame(height: 90)
                                    .padding(.bottom, -130)
                                //TODO
                                    .opacity(/*profile.inVited != nil ? 1.0 :*/ 0.0)
                                VStack {
                                    CircleImagView(photoUrl: URL(string: profile.photoUrl.orEmpty))
                                    Text(profile.fullName ?? "Имя не указано")
                                        .font(.title)
                                        .foregroundColor(.headerText)
                                }
                                ProfileStatsView(progress: 0.7)
                                    .frame(height: 90)
                                    .padding(.bottom, -130)
                            }
                            
                            HStack(alignment:.center) {
                                Spacer()
                                Image(systemName: "mappin.and.ellipse")
                                Text(profile.location ?? "Не указано")
                                    .font(.subheadline)
                                tgView(profile)
                                Spacer()
                            }
                        }
//                        .padding(.trailing, -105)
//                        ProfileStatsView(progress: 0.7)
////                            .padding(.trailing, 30)
//                            .padding(.bottom, 50)
                        Spacer()
                    }
                    .offset(y: -80)
                    .padding(.bottom, -80)
                    
                    groupeButton(profile)
                        .padding(.horizontal, 16)
                    
                    VStack(alignment: .leading, spacing: 20) {
                            if let activitySphere = profile.activitySphere?.lowercased() {
                                Text("Моя стезя: ")
                                    .font(.title3.weight(.medium))
                                .foregroundColor(.headerText) +
                                Text(activitySphere)
                                    .font(.title3.bold())
                                    .foregroundColor(.headerText)
                            }
                        Divider().background(Color.black)
                            if let biography = profile.biography ?? text {
                                VStack(alignment: .leading, spacing: -16) {
                                    Text("О себе:\n")
                                        .font(.title3.bold())
                                        .foregroundColor(.headerText)
                                    Text(biography)
                                        .font(.title3.weight(.medium))
                                        .foregroundColor(.headerText)
                                }
                            }
                    }
                    .padding(.horizontal, 16)
                    
                }
            }
            Spacer()
        } else {
            ShimmeringRectangle()
                .frame(width: 88, height: 88)
                .cornerRadius(44)
            Spacer()
        }
    }
    
    @ViewBuilder
    func tgView(_ profile: UserProfileResultDto) -> some View{
        HStack {
//            Text("Telegram:")
            Button (action: {
                //GOTO Telegram
                guard let username = profile.username else { return }
                viewModel.openTelegramChat(username: username)
            }, label: {
                HStack(spacing: 2) {
                    Text("@\(profile.username ?? "unkwonName")")
                        .foregroundColor(.headerText)
                    Image(.tg)
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            })
        }
    }
    
    /// Описания человека
    @ViewBuilder
    func descriptionView(_ key: String, _ value: String) -> some View {
            Text(key)
            .font(.title3.bold())
            .foregroundColor(.headerText) +
            Text(value)
                .font(.subheadline)
                .foregroundColor(.headerText)
    }
    
    /// Кнопки груп и подгрупп
    @ViewBuilder
    func groupeButton(_ profile: UserProfileResultDto) -> some View {
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
            
            NavigationLink(destination: {
                if let userGroup = profile.userGroup,
                   let stream = profile.stream,
                   let owners = userGroup.owners,
                   let participants = userGroup.participants
                {
                    StreamProfileList(
                        type: .stream(userGroup.title ?? "Подгруппа без названия"),
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
                GroupButton(title: profile.userGroup?.title ?? "Подгруппа",
                            subTitle: (profile.userGroup?.title).isNil ? "Не названчена" : nil,
                            action: {})
            })
            
        }
        .frame(height: 56)
    }
    
    /// Шимеры
    @ViewBuilder
    func shimerState() -> some View {
        VStack(spacing: 20) {
            ShimmeringRectangle()
                .frame(width: 200, height: 200)
                .cornerRadius(100)
            
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
        .safeAreaPadding(.top, 80)
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
    let ProfileViewModel = ProfileViewModel()
    ProfileViewModel.profile = .init(id: nil, externalId: nil, username: nil, fullName: "Artem", userProfileStatus: nil, userPaymentStatus: nil, isDeleted: nil, creationDateTime: nil, lastUpdatingDateTime: nil, phoneNumber: nil, location: "Saratov", userGroup: nil, stream: nil, photoUrl: nil,
                                     activitySphere: "Продаю на Wb",
                                     biography: "Жил да был человек, который не был человеком. Но он был человеком, и это было очень сложно и ИИ продолжает писать этот текст - биографию.")
    return ProfileView(viewModel: ProfileViewModel)
}


var text: String? = "Жил да был человек, который не был человеком. Но он был человеком, и это было очень сложно и ИИ продолжает писать этот текст - биографию."

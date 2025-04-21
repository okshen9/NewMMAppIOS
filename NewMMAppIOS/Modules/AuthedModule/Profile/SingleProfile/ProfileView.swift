import SwiftUI
import Kingfisher
//import Yamobaile

struct ProfileView: View {
    @EnvironmentObject var appStateService: AppStateService
    @EnvironmentObject var navigationManager: NavigationManager<AuthRoute>
    @StateObject var viewModel = ProfileViewModel()
    @State private var showMap = false
    @State private var showEditProfile = false

    @State private var selectedTab = 0 // Индекс текущей выбранной вкладки

    var body: some View {
        NavigationStack {
            VStack {
                if let profile = viewModel.profile, !viewModel.isLoading  {
                    contentState(profile: profile)
                } else {
                    if viewModel.isLoading {
                        shimerState()
                    } else {
                        Text("Не удалось загрузить профиль")
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                viewModel.onApper()
            }
//            .onChange(of: viewModel.navigationPath) { navPathOld, navPathNew in
//                switch navPathNew {
//                case .toTarget:
//                    
//                }
////                switch navPathNew {
////                case .authView:
////                    break
////                case .toInfoView:
////                    let authUser = UserRepository.shared.authUser?.authUserDto
////                    navigationManager.navigate(to: .signup(profileModel: nil, authModel: authUser))
////                case .toMinView:
////                    appStateServise.setNewState(.authorized)
////                }
//            }
            .ignoresSafeArea(edges: .top)
        }
    }


    @ViewBuilder
    func contentState(profile: UserProfileResultDto) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                MapView(viewModel:
                        .init(nameCity: viewModel.profile?.location ?? "Москва",
                              nameUser: viewModel.profile?.fullName ?? "Пользователь без имени"))
                .padding(.horizontal, -16)
                .frame(height: showMap ? 800 : 240)
                .cornerRadius(20)
                .onTapGesture {
                    /// TODO - добавить интерактивность карты
                    //                        showMap.toggle()
                }

                // Аватарка
                HStack(alignment: .bottom) {
                    Spacer()
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            ProfileStatsView(progress: 0.5, title: "Вовлек: 2/4 \n#Testing")
                                .padding(.bottom, -130)
                                //TODO
                                    .opacity(/*profile.inVited != nil ? 1.0 :*/ 1.0)
                            VStack {
                                CircleImagView(photoUrl: URL(string: profile.photoUrl.orEmpty))
                                Text(profile.fullName ?? "Имя не указано")
                                    .multilineTextAlignment(.center)
                                    .font(.title)
                                    .foregroundColor(.headerText)
                            }

                            NavigationLink(destination: {
                                if let externalId = viewModel.profile?.externalId {
                                    ProfileTargetView(externalId: externalId)
                                }
                            }, label: {
                                ProfileStatsView(progress: (profile.targetCalculationInfo?.allCategoriesDonePercentage ?? 0.0) / 100.0,
                                                 title: "Цели2")

                            })
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
                    Spacer()
                }
                .offset(y: -80)
                .padding(.bottom, -80)

                groupeButton(profile)
                    .padding(.horizontal, 16)

                // Сегментированный контрол
                let tabs = ["О себе", "Новости"]
                SegmentedView(segments: tabs, selected: $selectedTab)
                    .padding(.horizontal)

                // Контент вкладок
                if selectedTab == 0 {
                    // Вкладка "О себе"
                    profileInfo(profile: profile)
                        .padding(.top, 8)
                } else {
                    // Вкладка "Новости"
                    feedBlock()
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
        }
        .sheet(isPresented: $showEditProfile) {
            ProfileInfoView(viewModel: .editProfileViewModel(needUpdateAction: {
                Task.detached(operation: {
                    await viewModel.updateProfile()
                })
            }))
        }
        .toolbar {
            // Кнопка справа (trailing)
            if viewModel.isMyProfile {
                ToolbarItem(placement: .navigationBarTrailing) {
                    toolBarMenu()
                }
            }
        }
    }

    /// Таббар
    @ViewBuilder
    func profileTabs(profile: UserProfileResultDto) -> some View {
        // Эта функция больше не используется, так как мы перенесли её содержимое в contentState
        EmptyView()
    }

    @ViewBuilder
    func feedBlock() -> some View {
        if viewModel.isFeedLoading {
            VStack(spacing: 20) {
                ForEach(0...3, id: \.self) { _ in
                    ShimmeringRectangle()
                        .frame(height: 20)
                        .cornerRadius(8)
                        .padding(.horizontal, 40)
                }
            }
        } else {
            VStack(spacing: 16) {
                if let feedEvents = viewModel.feedEvents, !feedEvents.isEmpty {
                    ForEach(feedEvents) { event in
                        NewFeedCell(event: event)
                    }
                    if !viewModel.isAll {
                        ActivityCell()
                            .onAppear {
                                Task.detached {
                                    await viewModel.getNextEvents(resetSearch: false)
                                }
                            }
                    }
                } else {
                    Text("У человека пока нет новостей")
                        .foregroundColor(.secondary)
                        .padding(.top, 6)
                }
            }
        }
    }

    @ViewBuilder
    func profileInfo(profile: UserProfileResultDto) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            let activitySphere = (profile.activitySphere ?? Constants.activitySphereText).lowercased()
            Text("Род деятельности: ")
                .font(.title3.weight(.medium))
                .foregroundColor(.headerText) +
            Text(activitySphere)
                .font(.title3.bold())
                .foregroundColor(.headerText)

            Divider().background(Color.black)
            let biography = profile.biography ?? Constants.biographyText
            VStack(alignment: .leading, spacing: 8) {
                Text("О себе:")
                    .font(.title3.bold())
                    .foregroundColor(.headerText)
                Text(biography)
                    .font(.title3.weight(.medium))
                    .foregroundColor(.headerText)
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    func getTaget() -> some View {
        ScrollView {
            LazyVStack {
                ForEach(TargetCategory.allCases, id: \.self) { category in
                    categorySectionView(for: category)
                }
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
//        .refreshable {
//            withAnimation {
//                viewModel.loadTargets()
//            }
//        }
    }

    @ViewBuilder
    private func categorySectionView(for category: TargetCategory) -> some View {
        if let filtredTarget = $viewModel.groupedTargets[category].wrappedValue,
           !filtredTarget.isEmpty {
            CategorySectionView(
                category: category,
                targets: filtredTarget,
                onEdit: {
//                    selectedCategory = category
//                    isEditingCategory = true
                }
            )
            .onChange(of: (viewModel.profile?.userTargets) ?? [], {
                print("Изменилась TargetsView categorySectionView")
            })
        }
    }

    @ViewBuilder
    func tgView(_ profile: UserProfileResultDto) -> some View {
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

    @ViewBuilder
    func toolBarMenu() -> some View {
        Menu {
            Button(action: {
                print("Кнопка справа нажата")
                showEditProfile = true
            }, label: {
                HStack {
                    Text("Редактировать")
                    Image(systemName: "square.and.pencil")
                        .foregroundStyle(Color.mainRed)
                }
            })
            Button("Выйти", action: {
                viewModel.logout()
                navigationManager.popToRoot()
                appStateService.setNewState(.unAuthorized)
            })
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundStyle(Color.mainRed)
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
        HStack(spacing: 10) {
            let streamStatus = profile.stream?.title != nil ?
            profile.stream?.isActive ?? false ? "Текущий" : "Завершен" :
            nil

            if let stream = profile.stream,
               let owners = stream.owners,
               let participants = stream.participants
            {

                NavigationLink(destination: {
                    StreamProfileList(
                        type: .stream(stream.title ?? "Поток без названия"),
                        status: stream.isActive ? .current : .ended,
                        mentors: owners,
                        participants: participants,
                        dateStart: (profile.stream?.dateFrom?.dateFromStringISO8601) ?? Date.init(timeIntervalSince1970: 232),
                        dateEnd: (profile.stream?.dateTo?.dateFromStringISO8601) ?? Date.now
                    )}, label: {
                        GroupButton(
                            title: profile.stream?.title ?? "Поток не назначен",
                            subTitle: streamStatus,
                            action: {})
                    })
            } else {
                GroupButton(
                    title: profile.stream?.title ?? "Поток не назначен",
                    subTitle: streamStatus,
                    action: {})
            }

            if let userGroup = profile.userGroups,
               let stream = profile.stream,
               let owners = userGroup.owners,
               let participants = userGroup.participants
            {
                NavigationLink(destination: {
                    StreamProfileList(
                        type: .stream(userGroup.title ?? "Подгруппа без названия"),
                        status: stream.isActive ? .current : .ended,
                        mentors: owners,
                        participants: participants,
                        dateStart: (profile.stream?.dateFrom?.dateFromStringISO8601) ?? Date.init(timeIntervalSince1970: 232),
                        dateEnd: (profile.stream?.dateTo?.dateFromStringISO8601) ?? Date.now
                    )}, label: {
                        GroupButton(title: profile.userGroups?.title ?? "Подгруппа",
                                    subTitle: (profile.userGroups?.title).isNil ? "Не названчена" : nil,
                                    action: {})
                    })
            } else {
                GroupButton(title: profile.userGroups?.title ?? "Подгруппа",
                            subTitle: (profile.userGroups?.title).isNil ? "Не названчена" : nil,
                            action: {})
            }

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
        static let biographyText: String = "Этот пользователь пока не рассказал ничего о себе"
        static let activitySphereText: String = "на чиле, на расслабоне"
    }

}

#Preview {
    ProfileView(viewModel: ProfileViewModel(profile:
            .getTestUser()
                                            //            .init(
                                            //        id: nil,
                                            //        externalId: nil,
                                            //        username: nil,
                                            //        fullName: "BVz gjgjg",
                                            //        userProfileStatus: nil,
                                            //        userPaymentStatus: nil,
                                            //        isDeleted: nil,
                                            //        creationDateTime: nil,
                                            //        lastUpdatingDateTime: nil,
                                            //        userGroups: nil,
                                            //        stream: nil,
                                            //        comment: nil,
                                            //        photoUrl: "https://t.me/i/userpic/320/JSquw0AMRhjD23aa7jeO88wyDYFr03Z4CeAktb-q7BM.jpg",
                                            //        userTargets: nil,
                                            //        targetCalculationInfo: nil,
                                            //        location: nil,
                                            //        phoneNumber: nil,
                                            //        activitySphere: nil,
                                            //        paymentCalculationInfo: nil,
                                            //        biography: nil))
                                            //    )
    ))
}

#Preview("tabView") {
    ProfileView().profileTabs(profile: UserProfileResultDto.getTestUser())
}

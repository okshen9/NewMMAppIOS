import SwiftUI
import Kingfisher
//import Yamobaile

struct ProfileView: View {
    @Environment(\.navigationPath) private var path
    @EnvironmentObject var appStateService: AppNavigationStateService
    @EnvironmentObject var navigationManager: NavigationManager<AuthRoute>
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showMap = false
    @State private var showEditProfile = false
    
    @State private var selectedTab = 0 // Индекс текущей выбранной вкладки
    
    init(externalId: Int) {
        print("init ProfileView with externalId: \(externalId)")
        _viewModel = StateObject(wrappedValue: ProfileViewModel(externalId: externalId))
    }
    
    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    init() {
        _viewModel = StateObject(wrappedValue: ProfileViewModel())
    }
    
    var body: some View {
        ScrollView {
        VStack {
            
                if let profile = viewModel.profile, !viewModel.isLoading  {
                    contentState(profile: profile)
                } else {
                    if viewModel.isLoading {
                        shimerState()
                    } else {
                        Spacer()
                        Image(systemName: "person.crop.circle.badge.exclamationmark.fill")
                            .foregroundStyle(Color.mainRed)
                            .font(.system(size: 60))
                            .padding(.top, 200)
                        Text("Не удалось загрузить профиль")
                        
                    }
                }
            }
        }
        .scrollDisabled(showMap)
        .refreshable {
            viewModel.onApper(onReset: true)
        }
		.toolbar {
			// Кнопка справа (trailing)
            if !viewModel.isOtherProfile {
				ToolbarItem(placement: .navigationBarTrailing) {
					toolBarMenu()
				}
			}
		}
		
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.onApper()
        }
        .ignoresSafeArea(edges: .top)
        
    }
    
    
    @ViewBuilder
    func contentState(profile: UserProfileResultDto) -> some View {
            VStack(alignment: .leading, spacing: 16) {
                // Карта
                ZStack {
                    GeometryReader { geo in
                        MapView(canInteactive: showMap,
                                withSgift: !showMap,
                                viewModel: .init(nameCity: viewModel.profile?.location ?? "Москва",
                                                 nameUser: viewModel.profile?.fullName ?? "Пользователь без имени"))
                        .padding(.horizontal, -16)
                        .frame(height: showMap ? geo.size.height : Constants.heightMiniMap)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .onTapGesture {
                            if !showMap {
                                // Предварительно снимаем фокус с клавиатуры
                                UIApplication.shared.endEditing()
                                
                                // Используем более плавную анимацию при закрытии
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showMap.toggle()
                                }
                            }
                        }
                        .overlay(
                            Image(systemName: "chevron.up.circle.fill")
                                .resizable()
                                .foregroundColor(.mainRed)
                                .onTapGesture {
                                    UIApplication.shared.endEditing()
                                    // Используем более плавную анимацию при закрытии
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showMap.toggle()
                                    }
                                }
                                .frame(width: 34, height: 34)
                                .padding(16)
                                .opacity(showMap ? 1 : 0),
                            alignment: .bottomTrailing
                        )
                    }
                }
				.frame(height: showMap ? UIScreen.main.bounds.height - Constants.offestBigMap : Constants.heightMiniMap)
                
                // Профиль
                HStack(alignment: .bottom) {
                    Spacer()
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            // Статистика слева
                            //                            ProfileStatsView(progress: 0.5, title: "Вовлек: 2/4 \n#Testing")
                            //                                .padding(.bottom, -130)
                            //                                .opacity(1.0)
                            //                                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            
                            // Аватар и имя
                            VStack(spacing: 12) {
                                CircleImagView(photoUrl: URL(string: profile.photoUrl.orEmpty))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 4)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                
                                Text(profile.fullName ?? "ФИО не указано")
                                    .multilineTextAlignment(.center)
                                    .font(MMFonts.title)
                                    .foregroundColor(.headerText)
                            }
                            
                            // Статистика справа (Цели)
                            NavigationLink(destination: {
                                if let externalId = viewModel.profile?.externalId {
                                    ProfileTargetView(externalId: externalId)
                                }
                            }, label: {
                                ProfileStatsView(progress: (profile.targetCalculationInfo?.allCategoriesDonePercentage ?? 0.0) / 100.0,
                                                 title: "Цели")
                            })
                            .padding(.bottom, -130)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        // Локация и Telegram
                        HStack(alignment: .center, spacing: 16) {
                            Spacer()
                            // Локация
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.gray)
                                Text(profile.location ?? "Не указано")
                                    .font(MMFonts.subTitle)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(15)
                            
                            // Telegram
                            tgView(profile)
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .offset(y: -80)
                .padding(.bottom, -80)
                
                // Группы
                groupeButton(profile)
                    .padding(.horizontal, 16)
                
                // Табы
                VStack(spacing: 0) {
                    SegmentedView(segments: ["О себе", "Новости"], selected: $selectedTab)
                        .padding(.horizontal)
                    
                    // Разделитель под табами
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 1)
                        .padding(.top, 8)
                }
                
                // Контент табов
                if selectedTab == 0 {
                    profileInfo(profile: profile)
                    
                        .transition(.opacity)
                } else {
                    feedBlock()
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        .transition(.opacity)
                }
            }
        
        .animation(.easeInOut, value: selectedTab)
        .sheet(isPresented: $showEditProfile) {
            ProfileInfoView(viewModel: .editProfileViewModel(needUpdateAction: {
                Task.detached(operation: {
                    await viewModel.updateProfile()
                })
            }))
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
        VStack(spacing: 16) {
            if viewModel.isFeedLoading && viewModel.feedEvents.isEmptyOrNil {
                VStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { _ in
                        ShimmeringRectangle()
                            .frame(height: 60)
                            .cornerRadius(12)
                    }
                }
            } else if let feedEvents = viewModel.feedEvents, !feedEvents.isEmpty {
                ForEach(feedEvents) { event in
                    NewFeedCell(onHeaderTap: {}, event: event)
                }
                
                if !viewModel.isAll {
                    ActivityCell()
                        .frame(height: 50)
                        .onAppear {
                            if !viewModel.paginatingLoading {
                                Task.detached {
                                    await viewModel.getNextEvents(resetSearch: false)
                                }
                            }
                        }
                }
            } else {
                Text("У человека пока нет новостей")
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    func profileInfo(profile: UserProfileResultDto) -> some View {
		VStack(alignment: .leading, spacing: 24) {
			// Род деятельности
			VStack(alignment: .leading, spacing: 8) {
				Text("Род деятельности")
					.font(MMFonts.body)
					.foregroundColor(.headerText)
				
				Text((profile.activitySphere ?? Constants.activitySphereText).lowercased())
					.font(MMFonts.subTitle)
					.foregroundColor(.headerText)
			}
			.padding(.horizontal, 16)
			Divider()
				.padding(.horizontal, 16)
			
			// О себе
			let biography = profile.biography.isEmptyOrNil ? Constants.biographyText : profile.biography.orEmpty
			VStack(alignment: .leading, spacing: 8) {
				Text("О себе")
					.font(MMFonts.body)
					.foregroundColor(.headerText)
				
				Text(biography)
					.font(MMFonts.subTitle)
					.foregroundColor(.headerText)
					.fixedSize(horizontal: false, vertical: true)
			}
			.padding(.horizontal, 16)
			.padding(.bottom, 8)
		}
        .padding(.vertical, 6)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.bottom, 16)
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
        Button(action: {
            guard let username = profile.username else { return }
            viewModel.openTelegramChat(username: username)
        }) {
            HStack(spacing: 6) {
                Text("@\(profile.username ?? "unkwonName")")
                    .foregroundColor(.blue)
                Image(.tg)
                    .resizable()
                    .frame(width: 16, height: 16)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(15)
        }
    }
    
    @ViewBuilder
    func toolBarMenu() -> some View {
        Menu {
            if viewModel.isMyProfile && viewModel.profile != nil {
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
            }
            Button("Выйти", action: {
                viewModel.logout()
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
            .font(MMFonts.title)
            .foregroundColor(.headerText) +
        Text(value)
            .font(MMFonts.subTitle)
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
                    let dateEnd = stream.dateTo.orEmpty.dateFromStringISO8601 ?? Date.yesterday
                    StreamProfileList(
                        type: .stream(stream.title ?? "Поток без названия"),
                        status: dateEnd > Date() ? .current : .ended,
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
			// Группы человека
//			GroupButton(title: "Группы",
//						subTitle: "Не назначена",
//						action: {})
			// TODO: NESHKO
//            if let userGroup = profile.userGroups,
//               let stream = profile.stream,
//               let owners = userGroup.owners,
//               let participants = userGroup.participants
//            {
//                NavigationLink(destination: {
//                    StreamProfileList(
//                        type: .stream(userGroup.title ?? "Подгруппа без названия"),
//                        status: stream.isActive ? .current : .ended,
//                        mentors: owners,
//                        participants: participants,
//                        dateStart: (profile.stream?.dateFrom?.dateFromStringISO8601) ?? Date.init(timeIntervalSince1970: 232),
//                        dateEnd: (profile.stream?.dateTo?.dateFromStringISO8601) ?? Date.now
//                    )}, label: {
//                        GroupButton(title: profile.userGroups?.title ?? "Подгруппа",
//                                    subTitle: (profile.userGroups?.title).isNil ? "Не названчена" : nil,
//                                    action: {})
//                    })
//            } else {
//                GroupButton(title: profile.userGroups?.title ?? "Подгруппа",
//                            subTitle: (profile.userGroups?.title).isNil ? "Не названчена" : nil,
//                            action: {})
//            }
            
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
        static let activitySphereText: String = "Информация не указана"
		static let heightMiniMap = 240.0
		static let offestBigMap = 220.0
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
	TabView(content: {
		ProfileView().contentState(profile: UserProfileResultDto.getTestUser())
			.tabItem {
				Image(.MM)
					.renderingMode(.template)
				Text("Главная")
			}
			.tag(0)
	})
//    ProfileView().profileTabs(profile: UserProfileResultDto.getTestUser())
//	TabBarView {
//        ProfileView().contentState(profile: UserProfileResultDto.getTestUser())
//    }
}

// Добавьте расширение UIApplication для закрытия клавиатуры
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

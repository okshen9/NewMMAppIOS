import SwiftUI

struct TabBarView: View {
    @StateObject private var viewModel = TabBarViewModel()
    @State private var selectedTab = 0 // Индекс текущей выбранной вкладки

    var body: some View {
        if viewModel.user.isNil {
            LoadingViewScreenView()
                .onAppear {
                    viewModel.fetchUserProfile()
                }
        } else {
            TabView(selection: $selectedTab) {
                FeedView()
                    .tabItem {
                        Image(.MM)
                            .renderingMode(.template)
                            .foregroundColor(selectedTab == 0 ? Color.mainRed : Color.tabbarSecond)
                        
                        Text("Главная")
                            .foregroundColor(selectedTab == 0 ? Color.mainRed : Color.tabbarSecond)
                    }
                    .tag(0)
                
                EmptyView()
                    .tabItem {
                        Image(.search)
                            .renderingMode(.template)
                            .foregroundColor(selectedTab == 1 ? Color.mainRed : Color.tabbarSecond)
                        Text("Поиск")
                            .foregroundColor(selectedTab == 1 ? Color.mainRed : Color.tabbarSecond)
                    }
                    .tag(1)
                
                TargetsView()
                    .tabItem {
                        Image(.star)
                            .renderingMode(.template)
                            .foregroundColor(selectedTab == 2 ? Color.mainRed : Color.tabbarSecond)
                        Text("Цели")
                            .foregroundColor(selectedTab == 2 ? Color.mainRed : Color.orange)
                    }
                    .tag(2)
                
                EmptyView()
                    .tabItem {
                        Image(.pay)
                            .renderingMode(.template)
                            .foregroundColor(selectedTab == 3 ? Color.mainRed : Color.orange)
                        Text("Оплата")
                            .foregroundColor(selectedTab == 3 ? Color.mainRed : Color.orange)
                    }
                    .tag(3)
                
                ProfileView(index: selectedTab)
                    .tabItem {
                        VStack {
                            Image(.profile)
                                .renderingMode(.template)
                                .foregroundColor(selectedTab == 4 ? Color.green : Color.orange)
                            Text("Провиль")
                                .foregroundColor(selectedTab == 4 ? Color.mainRed : Color.orange)
                        }
                    }
                    .tag(4)
            }
            .accentColor(Color.mainRed)
            .foregroundColor(Color.tabbarSecond)
        }

        
        
    }
}

// MARK: - Constants
extension TabBarView {
    private enum Constants {
        static let title = "Выберите карту"
    }
}

#Preview {
    TabBarView()
}

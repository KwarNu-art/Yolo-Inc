import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0
    @ObservedObject var sessionManager = SessionManager.shared

    public init() {
        // Customize UIKit TabBar appearance for dark glacier theme
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.04, green: 0.07, blue: 0.12, alpha: 0.95)

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    public var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "gauge")
                    Text("Dashboard")
                }
                .tag(0)

            NavigationView {
                ApplicationsView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "gamecontroller.fill")
                Text("Games")
            }
            .tag(1)

            ActiveSessionView()
                .tabItem {
                    Image(systemName: "play.circle.fill")
                    Text("Session")
                }
                .badge(sessionManager.activeSession != nil ? "1" : nil)
                .tag(2)

            ThermalBatteryView()
                .tabItem {
                    Image(systemName: "thermometer.snowflake")
                    Text("Thermals")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(GlacierTheme.iceBlue)
    }
}

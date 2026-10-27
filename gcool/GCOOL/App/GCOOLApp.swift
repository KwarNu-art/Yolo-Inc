import SwiftUI

@main
struct GCOOLApp: App {
    @StateObject private var deviceMonitor = DeviceMonitorService.shared
    @StateObject private var sessionManager = SessionManager.shared
    @StateObject private var favoritesStore = FavoritesStore.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(deviceMonitor)
                .environmentObject(sessionManager)
                .environmentObject(favoritesStore)
                .preferredColorScheme(.dark) // Always dark glacier theme
        }
    }
}

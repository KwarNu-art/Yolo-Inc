import SwiftUI

public struct ActiveSessionView: View {
    @ObservedObject var sessionManager = SessionManager.shared
    @ObservedObject var deviceMonitor = DeviceMonitorService.shared
    @ObservedObject var shieldService = DistractionShieldService.shared
    @ObservedObject var favoritesStore = FavoritesStore.shared

    @State private var showingEndConfirmation = false
    @State private var sessionNotes = ""
    @State private var showingGuidedAccessModal = false

    public init() {}

    public var body: some View {
        NavigationView {
            ZStack {
                GlacierTheme.glacierGradient.ignoresSafeArea()
                SnowfallView()

                ScrollView {
                    VStack(spacing: 18) {
                        if let session = sessionManager.activeSession {
                            liveTimerDisplay(session)
                            pinnedGameCard(session)
                            thermalStatusCard(session)
                            focusShieldCard
                            sessionActions(session)
                        } else {
                            noActiveSessionState
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Gaming Session")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingGuidedAccessModal) {
                GuidedAccessGuideView()
            }
            .alert(isPresented: $showingEndConfirmation) {
                Alert(
                    title: Text("End Session?"),
                    message: Text("Total duration: \(sessionManager.currentElapsedDurationString). Summary will be saved to your device."),
                    primaryButton: .destructive(Text("End Session")) {
                        sessionManager.endSession(
                            finalThermal: deviceMonitor.currentThermalLevel,
                            finalBattery: deviceMonitor.batteryLevel,
                            notes: sessionNotes
                        )
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Live Timer Display
    private func liveTimerDisplay(_ session: GamingSession) -> some View {
        GlacierCard(borderColor: GlacierTheme.iceBlue.opacity(0.6)) {
            VStack(spacing: 8) {
                HStack {
                    Circle()
                        .fill(GlacierTheme.seasonalPine)
                        .frame(width: 8, height: 8)

                    Text("SESSION ACTIVE (WALL-CLOCK TIME)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(GlacierTheme.frostCyan)
                }

                Text(sessionManager.currentElapsedDurationString)
                    .font(.system(size: 42, weight: .bold, design: .monospaced))
                    .foregroundColor(GlacierTheme.snowWhite)
                    .padding(.vertical, 4)

                Text("Started at \(session.startTime, style: .time)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(GlacierTheme.silverSlate)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Pinned Game Card
    private func pinnedGameCard(_ session: GamingSession) -> some View {
        GlacierCard {
            HStack(spacing: 14) {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 26))
                    .foregroundColor(GlacierTheme.iceBlue)

                VStack(alignment: .leading, spacing: 3) {
                    Text(session.gameName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(GlacierTheme.snowWhite)

                    Text("Pinned Target Game")
                        .font(.system(size: 12))
                        .foregroundColor(GlacierTheme.silverSlate)
                }

                Spacer()

                if let game = favoritesStore.games.first(where: { $0.id == session.gameId }), game.isValidLaunchURL {
                    Button(action: {
                        favoritesStore.launchGame(game)
                    }) {
                        Text("Switch to Game")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(GlacierTheme.iceBlue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(GlacierTheme.iceBlue.opacity(0.15))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }

    // MARK: - Thermal Status Card
    private func thermalStatusCard(_ session: GamingSession) -> some View {
        GlacierCard(borderColor: GlacierTheme.thermalColor(for: deviceMonitor.currentThermalLevel).opacity(0.4)) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("LIVE THERMAL OBSERVATION")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(GlacierTheme.silverSlate)

                    Spacer()

                    Text(deviceMonitor.currentThermalLevel.badgeText)
                        .font(.system(size: 11, weight: .black))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(GlacierTheme.thermalColor(for: deviceMonitor.currentThermalLevel).opacity(0.2))
                        .foregroundColor(GlacierTheme.thermalColor(for: deviceMonitor.currentThermalLevel))
                        .cornerRadius(6)
                }

                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current State")
                            .font(.system(size: 11))
                            .foregroundColor(GlacierTheme.silverSlate)
                        Text(deviceMonitor.currentThermalLevel.rawValue)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(GlacierTheme.thermalColor(for: deviceMonitor.currentThermalLevel))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Peak in Session")
                            .font(.system(size: 11))
                            .foregroundColor(GlacierTheme.silverSlate)
                        Text(session.highestThermalLevel.rawValue)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(GlacierTheme.thermalColor(for: session.highestThermalLevel))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Battery Discharge")
                            .font(.system(size: 11))
                            .foregroundColor(GlacierTheme.silverSlate)
                        Text(deviceMonitor.batteryLevel >= 0 ? "\(Int(deviceMonitor.batteryLevel * 100))%" : "Unknown")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(GlacierTheme.snowWhite)
                    }
                }

                Text("Background execution note: iOS opportunistically sleeps GCOOL while you play. Upon returning to GCOOL, wall-clock duration is calculated accurately.")
                    .font(.system(size: 10))
                    .foregroundColor(GlacierTheme.silverSlate.opacity(0.8))
                    .padding(.top, 4)
            }
        }
    }

    // MARK: - Focus Shield Card
    private var focusShieldCard: some View {
        GlacierCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "bell.slash.fill")
                        .foregroundColor(GlacierTheme.iceBlue)

                    Text("Distraction Shield & Focus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(GlacierTheme.snowWhite)

                    Spacer()

                    Text(shieldService.isFocusShieldActive ? "ACTIVE" : "OFF")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(shieldService.isFocusShieldActive ? GlacierTheme.seasonalPine : GlacierTheme.silverSlate)
                }

                Text("On iOS 15, Apple's Screen Time self-authorization is unavailable. You can use iOS Guided Access to prevent notifications and home swipes during gameplay.")
                    .font(.system(size: 12))
                    .foregroundColor(GlacierTheme.silverSlate)

                HStack {
                    Button(action: {
                        if shieldService.isFocusShieldActive {
                            shieldService.stopFocusShield()
                        } else {
                            shieldService.startFocusShield()
                        }
                    }) {
                        Text(shieldService.isFocusShieldActive ? "Stop Focus Mode" : "Enable In-App Focus")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(GlacierTheme.iceBlue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(GlacierTheme.iceBlue.opacity(0.15))
                            .cornerRadius(8)
                    }

                    Spacer()

                    Button(action: {
                        showingGuidedAccessModal = true
                    }) {
                        HStack(spacing: 4) {
                            Text("Guided Access Setup")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(GlacierTheme.frostCyan)
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Session Actions
    private func sessionActions(_ session: GamingSession) -> some View {
        VStack(spacing: 12) {
            Button(action: {
                showingEndConfirmation = true
            }) {
                HStack {
                    Image(systemName: "stop.fill")
                    Text("End Gaming Session")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(GlacierTheme.berryRed)
                .cornerRadius(14)
                .shadow(color: GlacierTheme.berryRed.opacity(0.3), radius: 6, x: 0, y: 3)
            }
        }
    }

    // MARK: - No Active Session State
    private var noActiveSessionState: some View {
        GlacierCard {
            VStack(spacing: 14) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(GlacierTheme.iceBlue)

                Text("No Active Session")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(GlacierTheme.snowWhite)

                Text("Select a game from your catalog and tap 'Start Gaming Session' to track match time, thermal transitions, and battery drain.")
                    .font(.system(size: 13))
                    .foregroundColor(GlacierTheme.silverSlate)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                NavigationLink(destination: ApplicationsView()) {
                    Text("Browse Game Catalog")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(GlacierTheme.heroButtonGradient)
                        .cornerRadius(10)
                }
                .padding(.top, 6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }
}

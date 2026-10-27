import SwiftUI

public struct GameDetailView: View {
    @ObservedObject var favoritesStore = FavoritesStore.shared
    @ObservedObject var sessionManager = SessionManager.shared
    @ObservedObject var deviceMonitor = DeviceMonitorService.shared
    @ObservedObject var shieldService = DistractionShieldService.shared

    public let game: GameItem

    @State private var showingGuidedAccessGuide = false
    @State private var showingLaunchError = false
    @State private var launchErrorMessage = ""
    @Environment(\.presentationMode) var presentationMode

    public init(game: GameItem) {
        self.game = game
    }

    public var body: some View {
        ZStack {
            GlacierTheme.glacierGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    gameHeaderCard
                    sessionControlSection
                    lockingCapabilitiesSection
                    technicalNotesCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(game.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingGuidedAccessGuide) {
            GuidedAccessGuideView()
        }
        .alert(isPresented: $showingLaunchError) {
            Alert(
                title: Text("Cannot Open Game Directly"),
                message: Text(launchErrorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - Game Header
    private var gameHeaderCard: some View {
        GlacierCard {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(GlacierTheme.iceBlue.opacity(0.15))
                        .frame(width: 56, height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(GlacierTheme.iceBlue.opacity(0.4), lineWidth: 1)
                        )

                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 26))
                        .foregroundColor(GlacierTheme.iceBlue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(game.name)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(GlacierTheme.snowWhite)

                    Text(game.category)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(GlacierTheme.silverSlate)

                    if game.isPinnedAsActive {
                        HStack(spacing: 4) {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 10))
                            Text("Pinned as Active Game")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundColor(GlacierTheme.seasonalPine)
                        .padding(.top, 2)
                    }
                }

                Spacer()
            }
        }
    }

    // MARK: - Session Control Section
    private var sessionControlSection: some View {
        VStack(spacing: 12) {
            let isCurrentActiveSession = (sessionManager.activeSession?.gameId == game.id)

            if isCurrentActiveSession {
                GlacierCard(borderColor: GlacierTheme.iceBlue) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("CURRENTLY PLAYING")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(GlacierTheme.iceBlue)

                            Spacer()

                            Text(sessionManager.currentElapsedDurationString)
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(GlacierTheme.snowWhite)
                        }

                        Button(action: {
                            sessionManager.endSession(
                                finalThermal: deviceMonitor.currentThermalLevel,
                                finalBattery: deviceMonitor.batteryLevel
                            )
                        }) {
                            Text("End Gaming Session")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(GlacierTheme.berryRed)
                                .cornerRadius(12)
                        }
                    }
                }
            } else {
                Button(action: {
                    favoritesStore.pinGame(byId: game.id)
                    sessionManager.startSession(
                        for: game,
                        initialThermal: deviceMonitor.currentThermalLevel,
                        initialBattery: deviceMonitor.batteryLevel
                    )

                    // Attempt launch if URL scheme exists
                    if game.isValidLaunchURL {
                        favoritesStore.launchGame(game) { success in
                            if !success {
                                launchErrorMessage = "The scheme '\(game.launchURLScheme ?? "")' is not installed or supported on this device. Please open the game manually from your Home Screen. Your session timer is now actively running in GCOOL."
                                showingLaunchError = true
                            }
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                        Text("Start Gaming Session")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(GlacierTheme.heroButtonGradient)
                    .cornerRadius(14)
                    .shadow(color: GlacierTheme.iceBlue.opacity(0.35), radius: 8, x: 0, y: 4)
                }
            }

            // Pin / Unpin Button
            Button(action: {
                if game.isPinnedAsActive {
                    favoritesStore.unpinAll()
                } else {
                    favoritesStore.pinGame(byId: game.id)
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: game.isPinnedAsActive ? "pin.slash.fill" : "pin.fill")
                    Text(game.isPinnedAsActive ? "Unpin as Active Game" : "Pin as Active Game in GCOOL")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(game.isPinnedAsActive ? GlacierTheme.silverSlate : GlacierTheme.frostCyan)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(GlacierTheme.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(GlacierTheme.cardBorder, lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Locking Capabilities & Disclosures
    private var lockingCapabilitiesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("GAMING MODE LOCK CONTROLS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(GlacierTheme.silverSlate)

            // Lock 1: In-App Pinning
            GlacierCard {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "pin.circle.fill")
                            .foregroundColor(GlacierTheme.iceBlue)
                        Text("1. In-App Game Pinning")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(GlacierTheme.snowWhite)

                        Spacer()

                        Text(game.isPinnedAsActive ? "PINNED" : "IDLE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(game.isPinnedAsActive ? GlacierTheme.seasonalPine : GlacierTheme.silverSlate)
                    }

                    Text("Designates this game as the primary active session target in GCOOL for elapsed time calculation, thermal checks, and notes.")
                        .font(.system(size: 12))
                        .foregroundColor(GlacierTheme.silverSlate)
                }
            }

            // Lock 2: Distraction Shield (Screen Time Evaluation)
            GlacierCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "shield.lefthalf.filled")
                            .foregroundColor(Color.yellow)
                        Text("2. Screen Time Distraction Lock")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(GlacierTheme.snowWhite)

                        Spacer()

                        Text("iOS 16+ ONLY")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.yellow)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.yellow.opacity(0.15))
                            .cornerRadius(4)
                    }

                    Text("Apple introduced personal self-authorization in iOS 16. On iPhone 7 Plus (iOS 15.8.x), FamilyControls strictly requires an iCloud Family Sharing parent-managed account. GCOOL provides an honest in-app focus countdown instead.")
                        .font(.system(size: 12))
                        .foregroundColor(GlacierTheme.silverSlate)

                    Toggle(isOn: Binding(
                        get: { shieldService.isFocusShieldActive },
                        set: { enabled in
                            if enabled {
                                shieldService.startFocusShield()
                            } else {
                                shieldService.stopFocusShield()
                            }
                        }
                    )) {
                        Text("In-App Focus Countdown")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(GlacierTheme.snowWhite)
                    }
                    .padding(.top, 4)
                }
            }

            // Lock 3: Single-App Device Lockdown (Guided Access)
            GlacierCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lock.rectangle.fill")
                            .foregroundColor(GlacierTheme.seasonalPine)
                        Text("3. Hardware Single-App Lock")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(GlacierTheme.snowWhite)

                        Spacer()

                        Text("APPLE GUIDED ACCESS")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(GlacierTheme.seasonalPine)
                    }

                    Text("To lock your iPhone 7 Plus into this game so you cannot accidentally swipe home or pull down Notification Center, use iOS Guided Access.")
                        .font(.system(size: 12))
                        .foregroundColor(GlacierTheme.silverSlate)

                    Button(action: {
                        showingGuidedAccessGuide = true
                    }) {
                        HStack {
                            Text("View Guided Access Setup Guide")
                                .font(.system(size: 12, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(GlacierTheme.iceBlue)
                        .padding(.top, 2)
                    }
                }
            }
        }
    }

    // MARK: - Technical Notes Card
    private var technicalNotesCard: some View {
        GlacierCard {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "cpu")
                        .foregroundColor(GlacierTheme.frostCyan)
                    Text("A10 Fusion Device Profile")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(GlacierTheme.snowWhite)
                }

                Text(game.notes.isEmpty ? "Standard 60 Hz Retina HD profile. Monitor thermal state during extended matches." : game.notes)
                    .font(.system(size: 12))
                    .foregroundColor(GlacierTheme.silverSlate)
                    .lineSpacing(2)
            }
        }
    }
}

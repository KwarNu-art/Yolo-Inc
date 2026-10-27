import SwiftUI

public struct DashboardView: View {
    @ObservedObject var deviceMonitor = DeviceMonitorService.shared
    @ObservedObject var sessionManager = SessionManager.shared
    @ObservedObject var favoritesStore = FavoritesStore.shared

    @State private var showingEndSessionAlert = false
    @State private var sessionNotesInput = ""

    public init() {}

    public var body: some View {
        NavigationView {
            ZStack {
                GlacierTheme.glacierGradient.ignoresSafeArea()
                SnowfallView()

                ScrollView {
                    VStack(spacing: 18) {
                        headerView
                        activeSessionBanner
                        thermalMonitorCard
                        batteryAndHardwareCard
                        pinnedGameCard
                        quickTipsBanner
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: $showingEndSessionAlert) {
            Alert(
                title: Text("End Gaming Session?"),
                message: Text("Session duration: \(sessionManager.currentElapsedDurationString). Notes will be saved to your local history."),
                primaryButton: .destructive(Text("End Session")) {
                    sessionManager.endSession(
                        finalThermal: deviceMonitor.currentThermalLevel,
                        finalBattery: deviceMonitor.batteryLevel,
                        notes: sessionNotesInput
                    )
                },
                secondaryButton: .cancel()
            )
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("GCOOL")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(GlacierTheme.snowWhite)

                    Text("WINTER ❄️")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(GlacierTheme.iceBlue.opacity(0.2))
                        .foregroundColor(GlacierTheme.iceBlue)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(GlacierTheme.iceBlue.opacity(0.4), lineWidth: 1)
                        )
                }

                Text("\(deviceMonitor.deviceModelName) • iOS \(deviceMonitor.systemVersion) • 60 Hz")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(GlacierTheme.silverSlate)
            }

            Spacer()

            Button(action: {
                deviceMonitor.refreshSnapshot()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(GlacierTheme.iceBlue)
                    .padding(10)
                    .background(GlacierTheme.cardBackground)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(GlacierTheme.cardBorder, lineWidth: 1))
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Active Session Banner
    @ViewBuilder
    private var activeSessionBanner: some View {
        if let active = sessionManager.activeSession {
            GlacierCard(borderColor: GlacierTheme.iceBlue.opacity(0.6)) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(GlacierTheme.iceBlue)
                                .frame(width: 10, height: 10)

                            Text("GAMING SESSION ACTIVE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(GlacierTheme.iceBlue)
                        }

                        Spacer()

                        Text(sessionManager.currentElapsedDurationString)
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(GlacierTheme.snowWhite)
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(active.gameName)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(GlacierTheme.snowWhite)

                            Text("Started \(active.startTime, style: .time) • Peak: \(active.highestThermalLevel.badgeText)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(GlacierTheme.silverSlate)
                        }

                        Spacer()

                        Button(action: {
                            showingEndSessionAlert = true
                        }) {
                            Text("End Match")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(GlacierTheme.berryRed)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(GlacierTheme.berryRed.opacity(0.15))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(GlacierTheme.berryRed.opacity(0.3), lineWidth: 1)
                               Defaults    )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Thermal State Card
    private var thermalMonitorCard: some View {
        GlacierCard(borderColor: GlacierTheme.thermalColor(for: deviceMonitor.currentThermalLevel).opacity(0.45)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: deviceMonitor.currentThermalLevel.systemIconName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(GlacierTheme.thermalColor(for: deviceMonitor.currentThermalLevel))

                    Text("ProcessInfo.ThermalState")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(GlacierTheme.silverSlate)

                    Spacer()

                    Text(deviceMonitor.currentThermalLevel.badgeText)
                        .font(.system(size: 12, weight: .black))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(GlacierTheme.thermalColor(for: deviceMonitor.currentThermalLevel).opacity(0.2))
                        .foregroundColor(GlacierTheme.thermalColor(for: deviceMonitor.currentThermalLevel))
                        .cornerRadius(8)
                }

                Text(deviceMonitor.currentThermalLevel.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(GlacierTheme.snowWhite)

                Text(deviceMonitor.currentThermalLevel.explanation)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(GlacierTheme.silverSlate)
                    .lineSpacing(2)

                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 12))
                        .foregroundColor(GlacierTheme.iceBlue)

                    Text(deviceMonitor.currentThermalLevel.recommendedAction)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(GlacierTheme.frostCyan)
                }
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Battery & Power
    private var batteryAndHardwareCard: some View {
        HStack(spacing: 14) {
            // Battery Level
            GlacierCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: deviceMonitor.isCharging ? "bolt.batteryblock.fill" : "battery.75")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(GlacierTheme.iceBlue)

                        Spacer()

                        if deviceMonitor.isCharging {
                            Text("CHARGING")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(GlacierTheme.seasonalPine)
                        }
                    }

                    Text(deviceMonitor.batteryLevel >= 0 ? "\(Int(deviceMonitor.batteryLevel * 100))%" : "Unknown")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(GlacierTheme.snowWhite)

                    Text(deviceMonitor.isCharging ? "Generates extra charging heat" : "Battery discharging")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(GlacierTheme.silverSlate)
                }
            }

            // Low Power Mode
            GlacierCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "bolt.slash.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(deviceMonitor.isLowPowerMode ? Color.yellow : GlacierTheme.silverSlate)

                        Spacer()

                        Text(deviceMonitor.isLowPowerMode ? "ACTIVE" : "OFF")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(deviceMonitor.isLowPowerMode ? Color.yellow : GlacierTheme.silverSlate)
                    }

                    Text(deviceMonitor.isLowPowerMode ? "Low Power" : "Full Power")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(GlacierTheme.snowWhite)

                    Text(deviceMonitor.isLowPowerMode ? "A10 CPU/GPU downclocked" : "Optimal 60 FPS headroom")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(GlacierTheme.silverSlate)
                }
            }
        }
    }

    // MARK: - Pinned Game Quick Launch
    private var pinnedGameCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("PINNED ACTIVE GAME")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(GlacierTheme.silverSlate)

                Spacer()

                NavigationLink(destination: ApplicationsView()) {
                    Text("Change")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(GlacierTheme.iceBlue)
                }
            }

            if let pinned = favoritesStore.pinnedGame {
                GlacierCard {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(GlacierTheme.iceBlue.opacity(0.15))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(GlacierTheme.iceBlue.opacity(0.35), lineWidth: 1)
                                )

                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 22))
                                .foregroundColor(GlacierTheme.iceBlue)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(pinned.name)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(GlacierTheme.snowWhite)

                            Text(pinned.category)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(GlacierTheme.silverSlate)
                        }

                        Spacer()

                        if sessionManager.activeSession == nil {
                            Button(action: {
                                sessionManager.startSession(
                                    for: pinned,
                                    initialThermal: deviceMonitor.currentThermalLevel,
                                    initialBattery: deviceMonitor.batteryLevel
                                )
                                favoritesStore.launchGame(pinned)
                            }) {
                                Text("Start & Play")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(GlacierTheme.heroButtonGradient)
                                    .cornerRadius(10)
                                    .shadow(color: GlacierTheme.iceBlue.opacity(0.3), radius: 6, x: 0, y: 3)
                            }
                        }
                    }
                }
            } else {
                GlacierCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("No Game Pinned")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(GlacierTheme.snowWhite)

                            Text("Select a game from your catalog to track sessions.")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(GlacierTheme.silverSlate)
                        }

                        Spacer()

                        NavigationLink(destination: ApplicationsView()) {
                            Text("Select")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(GlacierTheme.iceBlue)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(GlacierTheme.iceBlue.opacity(0.15))
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Quick Tips
    private var quickTipsBanner: some View {
        NavigationLink(destination: OptimizationGuideView()) {
            GlacierCard(borderColor: GlacierTheme.iceBlue.opacity(0.3)) {
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.yellow)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("A10 Fusion Optimization Guide")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(GlacierTheme.snowWhite)

                        Text("7 practical engineering tips for sustained 60 FPS gaming.")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(GlacierTheme.silverSlate)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(GlacierTheme.silverSlate)
                }
            }
        }
    }
}

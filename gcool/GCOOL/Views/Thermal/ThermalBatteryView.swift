import SwiftUI

public struct ThermalBatteryView: View {
    @ObservedObject var deviceMonitor = DeviceMonitorService.shared

    public init() {}

    public var body: some View {
        NavigationView {
            ZStack {
                GlacierTheme.glacierGradient.ignoresSafeArea()
                SnowfallView()

                ScrollView {
                    VStack(spacing: 16) {
                        currentThermalCard
                        safeCoolingRecommendationsCard
                        unsafePracticesWarningCard
                        thermalLevelsGuideCard
                        recentSnapshotsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Thermals & Battery")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Current Thermal State
    private var currentThermalCard: some View {
        GlacierCard(borderColor: GlacierTheme.thermalColor(for: deviceMonitor.currentThermalLevel).opacity(0.6)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(GlacierTheme.thermalColor(for: deviceMonitor.currentThermalLevel).opacity(0.2))
                            .frame(width: 44, height: 44)

                        Image(systemName: deviceMonitor.currentThermalLevel.systemIconName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(GlacierTheme.thermalColor(for: deviceMonitor.currentThermalLevel))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(deviceMonitor.currentThermalLevel.title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(GlacierTheme.snowWhite)

                        Text("Status: \(deviceMonitor.currentThermalLevel.badgeText)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(GlacierTheme.thermalColor(for: deviceMonitor.currentThermalLevel))
                    }

                    Spacer()
                }

                Text(deviceMonitor.currentThermalLevel.explanation)
                    .font(.system(size: 13))
                    .foregroundColor(GlacierTheme.silverSlate)
                    .lineSpacing(2)

                HStack {
                    Text("Battery: \(deviceMonitor.batteryLevel >= 0 ? "\(Int(deviceMonitor.batteryLevel * 100))%" : "Unknown")")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(GlacierTheme.snowWhite)

                    Text("•")
                        .foregroundColor(GlacierTheme.silverSlate)

                    Text(deviceMonitor.isCharging ? "Charging" : "Discharging")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(deviceMonitor.isCharging ? Color.yellow : GlacierTheme.seasonalPine)

                    Text("•")
                        .foregroundColor(GlacierTheme.silverSlate)

                    Text(deviceMonitor.isLowPowerMode ? "LPM Active" : "Full Clocks")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(deviceMonitor.isLowPowerMode ? Color.yellow : GlacierTheme.frostCyan)
                }
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Safe Cooling Recommendations
    private var safeCoolingRecommendationsCard: some View {
        GlacierCard(borderColor: GlacierTheme.seasonalPine.opacity(0.4)) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(GlacierTheme.seasonalPine)
                    Text("SAFE COOLING PRACTICES")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(GlacierTheme.seasonalPine)
                }

                VStack(alignment: .leading, spacing: 8) {
                    safeRow(icon: "shield.slash", text: "Remove protective case during intensive 3D gaming to maximize aluminum unibody heat dissipation.")
                    safeRow(icon: "sun.min", text: "Lower screen brightness to 50–65%. The LCD backlight generates immediate chassis heat.")
                    safeRow(icon: "pause.fill", text: "Take a 5-minute break between competitive matches to let heat disperse via natural convection.")
                    safeRow(icon: "wind", text: "Place the phone near a gentle desk fan. Moving ambient air cools the aluminum rear panel rapidly.")
                }
            }
        }
    }

    private func safeRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(GlacierTheme.iceBlue)
                .frame(width: 20)
                .padding(.top, 2)

            Text(text)
                .font(.system(size: 12))
                .foregroundColor(GlacierTheme.snowWhite)
                .lineSpacing(2)
        }
    }

    // MARK: - Unsafe Practices Warning
    private var unsafePracticesWarningCard: some View {
        GlacierCard(borderColor: GlacierTheme.berryRed.opacity(0.4)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(GlacierTheme.berryRed)
                    Text("UNSAFE COOLING PRACTICES (AVOID)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(GlacierTheme.berryRed)
                }

                VStack(alignment: .leading, spacing: 6) {
                    unsafeRow(text: "NEVER put your iPhone in a refrigerator or freezer. Rapid cold causes internal moisture condensation that corrodes motherboard traces.")
                    unsafeRow(text: "NEVER apply ice cubes or cold wet packs directly to the screen or aluminum chassis. Water ingress risks liquid damage.")
                    unsafeRow(text: "The winter animation in GCOOL is aesthetic only. Software cannot physically cool electronic hardware.")
                }
            }
        }
    }

    private func unsafeRow(text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 13))
                .foregroundColor(GlacierTheme.berryRed)
                .frame(width: 20)
                .padding(.top, 2)

            Text(text)
                .font(.system(size: 12))
                .foregroundColor(GlacierTheme.silverSlate)
                .lineSpacing(2)
        }
    }

    // MARK: - Thermal Levels Guide
    private var thermalLevelsGuideCard: some View {
        GlacierCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("APPLE PROCESSINFO.THERMALSTATE REFERENCE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(GlacierTheme.silverSlate)

                VStack(spacing: 8) {
                    thermalLevelRow(level: .nominal, desc: "Normal operating temperatures. Full A10 CPU/GPU clocks.")
                    thermalLevelRow(level: .fair, desc: "Slightly elevated. Chassis warmth noticeable. Negligible throttle.")
                    thermalLevelRow(level: .serious, desc: "High heat. iOS begins dimming display and lowering peak GPU frequency.")
                    thermalLevelRow(level: .critical, desc: "Severe heat. Heavy frame drops as iOS throttles to prevent emergency shutdown.")
                }
            }
        }
    }

    private func thermalLevelRow(level: ThermalLevel, desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(level.badgeText)
                .font(.system(size: 10, weight: .black))
                .foregroundColor(GlacierTheme.thermalColor(for: level))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(GlacierTheme.thermalColor(for: level).opacity(0.15))
                .cornerRadius(4)
                .frame(width: 55, alignment: .leading)

            Text(desc)
                .font(.system(size: 11))
                .foregroundColor(GlacierTheme.silverSlate)

            Spacer()
        }
    }

    // MARK: - Recent Snapshots Section
    private var recentSnapshotsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RECENT SYSTEM SNAPSHOTS (IN-MEMORY)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(GlacierTheme.silverSlate)

            ForEach(deviceMonitor.thermalHistory.prefix(5)) { snap in
                GlacierCard {
                    HStack {
                        Image(systemName: snap.level.systemIconName)
                            .foregroundColor(GlacierTheme.thermalColor(for: snap.level))

                        Text(snap.level.rawValue)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(GlacierTheme.snowWhite)

                        Spacer()

                        Text("Battery: \(snap.formattedBatteryPercent)")
                            .font(.system(size: 11))
                            .foregroundColor(GlacierTheme.silverSlate)

                        Text(snap.timestamp, style: .time)
                            .font(.system(size: 11))
                            .foregroundColor(GlacierTheme.frostCyan)
                    }
                }
            }
        }
    }
}

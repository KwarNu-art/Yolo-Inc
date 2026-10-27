import SwiftUI

public struct SettingsView: View {
    @ObservedObject var sessionManager = SessionManager.shared
    @ObservedObject var favoritesStore = FavoritesStore.shared

    @State private var showingClearHistoryAlert = false
    @State private var showingResetDefaultsAlert = false
    @State private var showingExportSheet = false
    @State private var exportText = ""

    public init() {}

    public var body: some View {
        NavigationView {
            ZStack {
                GlacierTheme.glacierGradient.ignoresSafeArea()
                SnowfallView()

                ScrollView {
                    VStack(spacing: 16) {
                        historySection
                        dataManagementSection
                        guidesAndDisclosuresSection
                        aboutGCOOLSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("History & Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showingClearHistoryAlert) {
                Alert(
                    title: Text("Clear All Session History?"),
                    message: Text("This will remove all stored gaming duration logs from your local storage. This action cannot be undone."),
                    primaryButton: .destructive(Text("Clear History")) {
                        sessionManager.clearAllHistory()
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showingExportSheet) {
                exportSheetModal
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - History Section
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("GAMING SESSION HISTORY")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(GlacierTheme.silverSlate)

                Spacer()

                if !sessionManager.sessionHistory.isEmpty {
                    Text("\(sessionManager.sessionHistory.count) Sessions")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(GlacierTheme.frostCyan)
                }
            }

            if sessionManager.sessionHistory.isEmpty {
                GlacierCard {
                    HStack {
                        Spacer()
                        VStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 24))
                                .foregroundColor(GlacierTheme.silverSlate)

                            Text("No Past Sessions Recorded")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(GlacierTheme.snowWhite)

                            Text("Completed gaming sessions will be recorded here.")
                                .font(.system(size: 11))
                                .foregroundColor(GlacierTheme.silverSlate)
                        }
                        .padding(.vertical, 8)
                        Spacer()
                    }
                }
            } else {
                ForEach(sessionManager.sessionHistory.prefix(6)) { session in
                    GlacierCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(session.gameName)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(GlacierTheme.snowWhite)

                                Text("\(session.startTime, style: .date) • \(session.startTime, style: .time)")
                                    .font(.system(size: 11))
                                    .foregroundColor(GlacierTheme.silverSlate)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 3) {
                                Text(session.formattedDuration())
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(GlacierTheme.frostCyan)

                                Text("Peak: \(session.highestThermalLevel.badgeText)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(GlacierTheme.thermalColor(for: session.highestThermalLevel))
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Data Management Section
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DATA & PRIVACY CONTROLS")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(GlacierTheme.silverSlate)

            GlacierCard {
                VStack(spacing: 12) {
                    Button(action: {
                        prepareExportText()
                        showingExportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(GlacierTheme.iceBlue)
                            Text("Export Session Summaries (Plain Text)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(GlacierTheme.snowWhite)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(GlacierTheme.silverSlate)
                        }
                    }

                    Divider().background(GlacierTheme.cardBorder)

                    Button(action: {
                        showingClearHistoryAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(GlacierTheme.berryRed)
                            Text("Clear All Session History")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(GlacierTheme.berryRed)
                            Spacer()
                        }
                    }

                    Divider().background(GlacierTheme.cardBorder)

                    Button(action: {
                        favoritesStore.resetToDefaults()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(GlacierTheme.silverSlate)
                            Text("Reset Game Catalog to Defaults")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(GlacierTheme.silverSlate)
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Guides & Disclosures Section
    private var guidesAndDisclosuresSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ENGINEERING & DISCLOSURES")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(GlacierTheme.silverSlate)

            GlacierCard {
                VStack(spacing: 12) {
                    NavigationLink(destination: GuidedAccessGuideView()) {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(GlacierTheme.seasonalPine)
                            Text("Guided Access Setup Guide")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(GlacierTheme.snowWhite)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(GlacierTheme.silverSlate)
                        }
                    }

                    Divider().background(GlacierTheme.cardBorder)

                    NavigationLink(destination: LimitationsView()) {
                        HStack {
                            Image(systemName: "exclamationmark.shield")
                                .foregroundColor(Color.yellow)
                            Text("Technical Limitations & Feasibility Matrix")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(GlacierTheme.snowWhite)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(GlacierTheme.silverSlate)
                        }
                    }
                }
            }
        }
    }

    // MARK: - About GCOOL Section
    private var aboutGCOOLSection: some View {
        GlacierCard {
            VStack(spacing: 8) {
                HStack {
                    Text("GCOOL Winter Glacier")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(GlacierTheme.snowWhite)

                    Spacer()

                    Text("v1.0.0 (Build 1)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(GlacierTheme.silverSlate)
                }

                Text("Engineered for Apple A10 Fusion (iPhone 7 Plus) on iOS 15.0 – 15.8.x. Zero telemetry, zero analytics, strictly local persistence.")
                    .font(.system(size: 11))
                    .foregroundColor(GlacierTheme.silverSlate)
                    .lineSpacing(2)
            }
        }
    }

    // MARK: - Export Helper
    private func prepareExportText() {
        var text = "=== GCOOL GAMING SESSIONS EXPORT ===\n"
        text += "Export Date: \(Date())\n\n"
        for s in sessionManager.sessionHistory {
            text += "Game: \(s.gameName)\n"
            text += "Start: \(s.startTime)\n"
            text += "Duration: \(s.formattedDuration())\n"
            text += "Peak Thermal: \(s.highestThermalLevel.rawValue)\n"
            text += "Notes: \(s.sessionNotes.isEmpty ? "None" : s.sessionNotes)\n"
            text += "----------------------------------------\n"
        }
        self.exportText = text
    }

    private var exportSheetModal: some View {
        NavigationView {
            ZStack {
                GlacierTheme.backgroundDark.ignoresSafeArea()
                ScrollView {
                    Text(exportText)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(GlacierTheme.snowWhite)
                        .padding()
                }
            }
            .navigationTitle("Session Export")
            .navigationBarItems(
                leading: Button("Copy") {
                    UIPasteboard.general.string = exportText
                },
                trailing: Button("Done") {
                    showingExportSheet = false
                }
            )
        }
    }
}

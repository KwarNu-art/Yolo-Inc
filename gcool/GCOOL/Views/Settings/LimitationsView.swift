import SwiftUI

public struct LimitationsView: View {
    public init() {}

    public var body: some View {
        ZStack {
            GlacierTheme.glacierGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    feasibilityMatrixSection
                    developerDeclarationCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Technical Limitations")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        GlacierCard {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(GlacierTheme.iceBlue)
                    Text("Technical Honesty Constitution")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(GlacierTheme.snowWhite)
                }

                Text("GCOOL does not compromise correctness for marketing claims. Standard third-party iOS applications operate under strict sandboxing. Below is the verified feasibility matrix for iPhone 7 Plus running iOS 15.x.")
                    .font(.system(size: 12))
                    .foregroundColor(GlacierTheme.silverSlate)
                    .lineSpacing(2)
            }
        }
    }

    private var feasibilityMatrixSection: some View {
        VStack(spacing: 12) {
            matrixCard(
                feature: "Active Session Wall-Clock Timing",
                status: "SUPPORTED",
                statusColor: GlacierTheme.seasonalPine,
                desc: "Calculated accurately from persisted Date timestamps upon app suspension and return."
            )
            matrixCard(
                feature: "ProcessInfo.ThermalState Monitoring",
                status: "SUPPORTED",
                statusColor: GlacierTheme.seasonalPine,
                desc: "Public Apple API providing Nominal, Fair, Serious, and Critical thermal pressure states."
            )
            matrixCard(
                feature: "In-App Game Pinning",
                status: "SUPPORTED",
                statusColor: GlacierTheme.seasonalPine,
                desc: "Pins your active game inside GCOOL's UI to track dedicated session duration and notes."
            )
            matrixCard(
                feature: "Personal Screen Time App Blocking",
                status: "UNSUPPORTED ON iOS 15",
                statusColor: Color.yellow,
                desc: "Apple introduced self-authorization in iOS 16.0. On iOS 15 (iPhone 7 Plus cap), FamilyControls strictly requires an iCloud Family Sharing parent account."
            )
            matrixCard(
                feature: "Automatic Installed Apps Discovery",
                status: "UNSUPPORTED IN SANDBOX",
                statusColor: Color.yellow,
                desc: "Sandboxed apps cannot query all bundle IDs on the device. GCOOL uses a user-managed favorites catalog."
            )
            matrixCard(
                feature: "Forced CPU/GPU Overclocking",
                status: "IMPOSSIBLE IN SOFTWARE",
                statusColor: GlacierTheme.berryRed,
                desc: "SoC clock frequencies are governed exclusively by the XNU kernel and Apple power management."
            )
            matrixCard(
                feature: "System-wide Single-App Lockdown",
                status: "MANUAL ONLY",
                statusColor: GlacierTheme.iceBlue,
                desc: "Standard third-party apps cannot force lockdown. Use built-in iOS Guided Access (triple-click Home Button)."
            )
        }
    }

    private func matrixCard(feature: String, status: String, statusColor: Color, desc: String) -> some View {
        GlacierCard {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(feature)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(GlacierTheme.snowWhite)

                    Spacer()

                    Text(status)
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(statusColor.opacity(0.15))
                        .cornerRadius(4)
                }

                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(GlacierTheme.silverSlate)
                    .lineSpacing(2)
            }
        }
    }

    private var developerDeclarationCard: some View {
        GlacierCard {
            VStack(alignment: .leading, spacing: 6) {
                Text("Zero Analytics & Zero Telemetry")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(GlacierTheme.snowWhite)

                Text("GCOOL stores session history and favorite games 100% locally on your iPhone 7 Plus via JSON document files. No servers, no tracking, no ads.")
                    .font(.system(size: 11))
                    .foregroundColor(GlacierTheme.silverSlate)
            }
        }
    }
}

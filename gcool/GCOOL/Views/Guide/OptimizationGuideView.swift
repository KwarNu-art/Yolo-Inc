import SwiftUI

public struct OptimizationGuideView: View {
    @State private var selectedCategory = "All"

    private let categories = ["All", "Thermals & Battery", "Performance", "Memory & CPU", "Storage", "Focus & Locking"]

    private var filteredTips: [OptimizationTip] {
        if selectedCategory == "All" {
            return OptimizationTip.tips
        } else {
            return OptimizationTip.tips.filter { $0.category.contains(selectedCategory) }
        }
    }

    public init() {}

    public var body: some View {
        ZStack {
            GlacierTheme.glacierGradient.ignoresSafeArea()
            SnowfallView()

            ScrollView {
                VStack(spacing: 16) {
                    categoryFilterRow
                    engineeringTruthBanner
                    tipsList
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("A10 Optimization Guide")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Category Filter Row
    private var categoryFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { cat in
                    Button(action: {
                        selectedCategory = cat
                    }) {
                        Text(cat)
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(selectedCategory == cat ? GlacierTheme.iceBlue.opacity(0.25) : GlacierTheme.cardBackground)
                            .foregroundColor(selectedCategory == cat ? GlacierTheme.frostCyan : GlacierTheme.silverSlate)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedCategory == cat ? GlacierTheme.iceBlue : GlacierTheme.cardBorder, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - Engineering Truth Banner
    private var engineeringTruthBanner: some View {
        GlacierCard {
            HStack(spacing: 12) {
                Image(systemName: "cpu.fill")
                    .foregroundColor(GlacierTheme.iceBlue)
                    .font(.system(size: 20))

                VStack(alignment: .leading, spacing: 3) {
                    Text("iPhone 7 Plus Hardware Profile")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(GlacierTheme.snowWhite)

                    Text("A10 Fusion SoC (2x Hurricane + 2x Zephyr cores), PowerVR Series7XT Plus GPU, 3 GB LPDDR4 RAM, 60 Hz Retina HD display. Sustainable 60 FPS requires balancing visual fidelity against thermal generation.")
                        .font(.system(size: 11))
                        .foregroundColor(GlacierTheme.silverSlate)
                        .lineSpacing(2)
                }
            }
        }
    }

    // MARK: - Tips List
    private var tipsList: some View {
        VStack(spacing: 14) {
            ForEach(filteredTips) { tip in
                GlacierCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(GlacierTheme.iceBlue.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                Image(systemName: tip.iconName)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(GlacierTheme.iceBlue)
                            }

                            VStack(alignment: .leading, spacing: 1) {
                                Text(tip.title)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(GlacierTheme.snowWhite)

                                Text(tip.category)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(GlacierTheme.frostCyan)
                            }

                            Spacer()
                        }

                        Text(tip.summary)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(GlacierTheme.snowWhite)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Technical Rationale:")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(GlacierTheme.silverSlate)

                            Text(tip.technicalRationale)
                                .font(.system(size: 12))
                                .foregroundColor(GlacierTheme.silverSlate)
                                .lineSpacing(2)
                        }

                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 11))
                                .foregroundColor(GlacierTheme.seasonalPine)
                                .padding(.top, 2)

                            Text(tip.recommendedSetting)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(GlacierTheme.seasonalPine)
                        }
                        .padding(.top, 2)
                    }
                }
            }
        }
    }
}

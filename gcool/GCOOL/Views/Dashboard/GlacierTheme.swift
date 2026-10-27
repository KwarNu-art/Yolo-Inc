import SwiftUI

/// Premium Winter / Glacier Cooling Design System for GCOOL.
/// Palette: Midnight glacier navy, icy crystalline blue, arctic cyan, snow white, and silver frost accents.
public struct GlacierTheme {
    // Core Colors
    public static let backgroundDark = Color(red: 0.04, green: 0.07, blue: 0.12) // #0A121F
    public static let cardBackground = Color(red: 0.07, green: 0.11, blue: 0.18).opacity(0.85) // Frosted Navy
    public static let cardBorder = Color(red: 0.22, green: 0.58, blue: 0.88).opacity(0.35) // Icy border
    public static let iceBlue = Color(red: 0.22, green: 0.74, blue: 0.97) // #38BDF8
    public static let frostCyan = Color(red: 0.65, green: 0.95, blue: 0.99) // #A5F3FC
    public static let glacierGlow = Color(red: 0.15, green: 0.50, blue: 0.85) // Deep cyan glow
    public static let snowWhite = Color(red: 0.97, green: 0.98, blue: 1.0)
    public static let silverSlate = Color(red: 0.58, green: 0.64, blue: 0.72)
    public static let seasonalPine = Color(red: 0.20, green: 0.70, blue: 0.45) // Restrained festive evergreen
    public static let berryRed = Color(red: 0.92, green: 0.28, blue: 0.35) // Restrained festive cranberry

    // Thermal Colors
    public static func thermalColor(for level: ThermalLevel) -> Color {
        switch level {
        case .nominal: return iceBlue
        case .fair: return Color.yellow
        case .serious: return Color.orange
        case .critical: return Color.red
        case .unknown: return silverSlate
        }
    }

    // Gradients
    public static let glacierGradient = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.09, blue: 0.16),
            Color(red: 0.02, green: 0.04, blue: 0.08)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let heroButtonGradient = LinearGradient(
        colors: [
            Color(red: 0.15, green: 0.65, blue: 0.95),
            Color(red: 0.08, green: 0.42, blue: 0.80)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let cardHeaderGradient = LinearGradient(
        colors: [
            frostCyan.opacity(0.15),
            Color.clear
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

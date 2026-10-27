import Foundation

/// Represents a game in GCOOL's gaming catalog.
/// Since standard iOS sandboxing prevents enumerating third-party installed apps without MDM or private APIs,
/// GCOOL provides a user-curated catalog supporting custom entries and verified URL schemes/universal links.
public struct GameItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var category: String
    public var launchURLScheme: String?
    public var notes: String
    public var isPinnedAsActive: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        category: String = "Action / MOBA",
        launchURLScheme: String? = nil,
        notes: String = "",
        isPinnedAsActive: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.launchURLScheme = launchURLScheme
        self.notes = notes
        self.isPinnedAsActive = isPinnedAsActive
        self.createdAt = createdAt
    }

    /// Validates if the launch URL scheme is well-formed.
    public var isValidLaunchURL: Bool {
        guard let scheme = launchURLScheme, !scheme.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        guard let url = URL(string: scheme) else { return false }
        return url.scheme != nil
    }

    /// Built-in popular defaults with verified public URL schemes where available.
    public static var defaults: [GameItem] {
        [
            GameItem(
                name: "Mobile Legends: Bang Bang",
                category: "MOBA (5v5)",
                launchURLScheme: "mobilelegends://",
                notes: "A10 Fusion recommendation: High graphics, 60 FPS cap, shadows OFF for sustained thermals.",
                isPinnedAsActive: true
            ),
            GameItem(
                name: "PUBG MOBILE",
                category: "Battle Royale",
                launchURLScheme: "pubgmobile://",
                notes: "Smooth graphics + Extreme frame rate produces the lowest thermal throttling on iPhone 7 Plus.",
                isPinnedAsActive: false
            ),
            GameItem(
                name: "Genshin Impact",
                category: "Open World RPG",
                launchURLScheme: "genshinimpact://",
                notes: "Very demanding on A10 Hurricane cores. Low preset at 30/60 FPS with motion blur off is recommended.",
                isPinnedAsActive: false
            ),
            GameItem(
                name: "Call of Duty: Mobile",
                category: "First Person Shooter",
                launchURLScheme: "codm://",
                notes: "Medium graphics + Max frame rate ensures optimal touch response without overheating.",
                isPinnedAsActive: false
            ),
            GameItem(
                name: "Subway Surfers",
                category: "Endless Runner",
                launchURLScheme: "subwaysurfers://",
                notes: "Lightweight title, runs at locked 60 FPS on iPhone 7 Plus with nominal thermal footprint.",
                isPinnedAsActive: false
            )
        ]
    }
}

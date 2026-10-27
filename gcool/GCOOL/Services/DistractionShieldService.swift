import Foundation
import Combine
import UIKit

/// Distraction Shield & Focus Manager with technical honesty.
///
/// On iOS 15 (iPhone 7 Plus maximum supported OS):
/// - Individual self-authorization (`AuthorizationCenter.shared.requestAuthorization(for: .individual)`) does not exist; it was introduced in iOS 16.0.
/// - The `FamilyControls` framework on iOS 15 was strictly designed for parent/child iCloud Family Sharing (`.child`).
/// - GCOOL discloses this limitation clearly and offers an honest, in-app Focus Shield with Do Not Disturb guidance and a Guided Access walkthrough.
public class DistractionShieldService: ObservableObject {
    public static let shared = DistractionShieldService()

    @Published public private(set) var isFocusShieldActive: Bool = false
    @Published public private(set) var focusStartTime: Date?
    @Published public private(set) var selectedDistractingApps: Set<String> = []

    public init() {}

    /// Starts in-app Focus Shield for the session.
    public func startFocusShield() {
        self.isFocusShieldActive = true
        self.focusStartTime = Date()
    }

    /// Stops the Focus Shield.
    public func stopFocusShield() {
        self.isFocusShieldActive = false
        self.focusStartTime = nil
    }

    /// Toggles a distraction category (e.g. "Social Media", "Short Video", "Instant Messaging").
    public func toggleDistractionCategory(_ category: String) {
        if selectedDistractingApps.contains(category) {
            selectedDistractingApps.remove(category)
        } else {
            selectedDistractingApps.insert(category)
        }
    }

    /// Common distraction categories for in-app tracking.
    public static let commonCategories = [
        "Social Networking (TikTok, Instagram, X)",
        "Instant Messaging Notifications (Telegram, WhatsApp)",
        "Short Videos & Live Streams (YouTube Shorts)",
        "Email & Work Communications (Slack, Gmail)"
    ]
}

import Foundation

/// Technical reality disclosure regarding Screen Time, FamilyControls, and App Locking on iOS 15.
public struct ScreenTimeFeasibility {
    public enum CapabilityStatus {
        case available
        case restrictedByOSVersion(required: String, current: String)
        case missingEntitlement(entitlement: String)
        case unsupportedBySandbox
    }

    /// Evaluates the true availability of individual distraction blocking on the current operating environment.
    public static var individualAuthorizationStatus: CapabilityStatus {
        // Individual self-authorization AuthorizationCenter.shared.requestAuthorization(for: .individual)
        // was introduced by Apple in iOS 16.0.
        // The iPhone 7 Plus is permanently capped at iOS 15.8.x.
        if #available(iOS 16.0, *) {
            return .available
        } else {
            let currentVersion = UIDevice.current.systemVersion
            return .restrictedByOSVersion(
                required: "iOS 16.0+",
                current: "iOS \(currentVersion)"
            )
        }
    }

    /// Clarifies the 4 distinct meanings of "Lock" for user transparency.
    public static let lockMeanings: [(title: String, subtitle: String, canGCOOLDoIt: Bool, explanation: String)] = [
        (
            title: "1. In-App Game Pinning",
            subtitle: "Select & pin the active game in GCOOL",
            canGCOOLDoIt: true,
            explanation: "GCOOL designates the chosen game as the active target for session timing, thermal tracking, and post-match notes."
        ),
        (
            title: "2. Screen Time Distraction Restriction",
            subtitle: "Block distracting apps during gameplay",
            canGCOOLDoIt: false,
            explanation: "Requires iOS 16.0+ for individual self-authorization or an iCloud Family Sharing parent-managed account with com.apple.developer.family-controls entitlement."
        ),
        (
            title: "3. Keep Game in RAM / Prevent OS Termination",
            subtitle: "Force game to never be killed by iOS",
            canGCOOLDoIt: false,
            explanation: "Impossible in standard third-party iOS architecture. The iOS memory manager (Jetsam) terminates background processes at its own discretion based on system-wide memory pressure."
        ),
        (
            title: "4. Single-App Device Lockdown",
            subtitle: "Prevent exiting the game accidentally",
            canGCOOLDoIt: false, // Handled manually via iOS Guided Access
            explanation: "Third-party apps cannot force the system into single-app mode. Apple provides 'Guided Access' (Settings -> Accessibility -> Guided Access) which triple-clicks the Home button to lock the device into any open game."
        )
    ]
}

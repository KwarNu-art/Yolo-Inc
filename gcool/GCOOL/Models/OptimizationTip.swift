import Foundation

public struct OptimizationTip: Identifiable, Codable, Equatable {
    public let id: String
    public let title: String
    public let category: String
    public let iconName: String
    public let summary: String
    public let technicalRationale: String
    public let recommendedSetting: String

    public static var tips: [OptimizationTip] {
        [
            OptimizationTip(
                id: "display_brightness",
                title: "Display Backlight & Thermal Coupling",
                category: "Thermals & Battery",
                iconName: "sun.max.fill",
                summary: "Lower screen brightness to 50–70% indoors.",
                technicalRationale: "The iPhone 7 Plus LCD backlight draws substantial current at 100% brightness, heating the display panel directly adjacent to the A10 SoC board.",
                recommendedSetting: "50% - 65% brightness with True Tone/Night Shift off during competitive matches."
            ),
            OptimizationTip(
                id: "case_heat_sink",
                title: "Remove Thick Insulating Phone Cases",
                category: "Thermals",
                iconName: "shield.slash.fill",
                summary: "Remove thick silicone/leather cases during intensive 3D sessions.",
                technicalRationale: "The iPhone 7 Plus uses its aluminum unibody chassis as its primary passive heat sink. Thick cases trap thermal radiation, accelerating core throttling.",
                recommendedSetting: "Play with device bare or use an open-back gaming bumper."
            ),
            OptimizationTip(
                id: "low_power_tradeoff",
                title: "Low Power Mode FPS Trade-off",
                category: "Performance",
                iconName: "battery.50",
                summary: "Keep Low Power Mode OFF if you require sustained 60 FPS.",
                technicalRationale: "Low Power Mode downclocks the A10 CPU cores and throttles GPU throughput, which causes frame drops in MOBA/Shooter teamfights.",
                recommendedSetting: "Disable Low Power Mode before competitive matches; enable it only when cooling down."
            ),
            OptimizationTip(
                id: "charging_heat",
                title: "Avoid Heavy Gaming While Fast Charging",
                category: "Thermals & Battery",
                iconName: "bolt.fill",
                summary: "Charge to 80% before matches rather than playing while plugged into high-wattage chargers.",
                technicalRationale: "Battery chemical heat during charging combined with A10 GPU rendering heat triggers iOS ThermalState.serious within 10–15 minutes.",
                recommendedSetting: "Unplug charging cable during matches or cap charger to 5W standard USB."
            ),
            OptimizationTip(
                id: "background_refresh",
                title: "Disable Background App Refresh",
                category: "Memory & CPU",
                iconName: "arrow.triangle.2.circlepath",
                summary: "Turn off background refresh in iOS Settings.",
                technicalRationale: "The iPhone 7 Plus has 3 GB LPDDR4 RAM. Background daemons fetching data compete with modern game assets for memory allocation.",
                recommendedSetting: "iOS Settings -> General -> Background App Refresh -> Off."
            ),
            OptimizationTip(
                id: "storage_headroom",
                title: "Maintain 10% Flash Storage Headroom",
                category: "Storage",
                iconName: "internaldrive.fill",
                summary: "Keep at least 3–5 GB of free storage on your device.",
                technicalRationale: "When NVMe/NAND storage is nearly full, APFS filesystem writes and swap cache slow down, causing micro-stutters during game asset streaming.",
                recommendedSetting: "Offload unused media/apps to maintain at least 4 GB free."
            ),
            OptimizationTip(
                id: "guided_access_gesture",
                title: "Use Guided Access to Block Accidental Touches",
                category: "Focus & Locking",
                iconName: "lock.fill",
                summary: "Enable Guided Access to lock controls and suppress Notification Center.",
                technicalRationale: "Accidentally swiping down the top Notification Center or Control Center during combat freezes game input for several frames.",
                recommendedSetting: "Triple-click Home button to enter Guided Access when match begins."
            )
        ]
    }
}

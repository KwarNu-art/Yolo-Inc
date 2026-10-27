import Foundation
import UIKit

/// Honest representation of Apple's ProcessInfo.ThermalState.
/// Standard sandbox apps have no access to raw Celsius/Fahrenheit sensors or internal thermistor registers.
/// ProcessInfo.ThermalState reflects Apple's system thermal pressure management.
public enum ThermalLevel: String, Codable, CaseIterable {
    case nominal = "Nominal"
    case fair = "Fair"
    case serious = "Serious"
    case critical = "Critical"
    case unknown = "Unknown"

    public init(from processInfoState: ProcessInfo.ThermalState) {
        switch processInfoState {
        case .nominal:
            self = .nominal
        case .fair:
            self = .fair
        case .serious:
            self = .serious
        case .critical:
            self = .critical
        @unknown default:
            self = .unknown
        }
    }

    public var title: String {
        switch self {
        case .nominal: return "Nominal (Optimal)"
        case .fair: return "Fair (Elevated)"
        case .serious: return "Serious (Throttling Risk)"
        case .critical: return "Critical (Immediate Cool-Down Needed)"
        case .unknown: return "Unknown State"
        }
    }

    public var badgeText: String {
        switch self {
        case .nominal: return "COOL"
        case .fair: return "WARM"
        case .serious: return "HOT"
        case .critical: return "ALERT"
        case .unknown: return "N/A"
        }
    }

    public var explanation: String {
        switch self {
        case .nominal:
            return "Thermal pressure is nominal. The Apple A10 Fusion SoC operates at full frequency with no thermal clock throttling."
        case .fair:
            return "Thermals are slightly elevated. Fans/chassis heat dissipation is working normally. Minimal to no perceptible throttling in games."
        case .serious:
            return "Device is significantly hot. iOS has likely begun reducing display brightness and lowering peak GPU clocks to protect hardware."
        case .critical:
            return "Critical thermal threshold reached. iOS will aggressively throttle CPU/GPU frequencies to prevent thermal shutdown. Suspend heavy 3D rendering immediately."
        case .unknown:
            return "Thermal state could not be queried from the kernel subsystem."
        }
    }

    public var recommendedAction: String {
        switch self {
        case .nominal:
            return "All conditions ideal for 60 FPS gaming."
        case .fair:
            return "Consider lowering screen brightness slightly if planning extended multi-hour sessions."
        case .serious:
            return "Pause high-fidelity games. Remove heavy insulating cases. Allow passive room-air cooling."
        case .critical:
            return "Exit the game now. Disconnect charging cable. Do NOT place phone in a freezer or apply ice directly (risk of internal condensation damage)."
        case .unknown:
            return "Observe physical chassis temperature manually."
        }
    }

    public var systemIconName: String {
        switch self {
        case .nominal: return "snowflake"
        case .fair: return "wind"
        case .serious: return "flame"
        case .critical: return "exclamationmark.triangle.fill"
        case .unknown: return "questionmark.circle"
        }
    }
}

public struct ThermalSnapshot: Identifiable, Codable, Equatable {
    public let id: UUID
    public let timestamp: Date
    public let level: ThermalLevel
    public let batteryLevel: Float // 0.0 to 1.0 (-1.0 if unknown)
    public let isLowPowerMode: Bool
    public let isCharging: Bool

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        level: ThermalLevel,
        batteryLevel: Float,
        isLowPowerMode: Bool,
        isCharging: Bool
    ) {
        self.id = id
        self.timestamp = timestamp
        self.level = level
        self.batteryLevel = batteryLevel
        self.isLowPowerMode = isLowPowerMode
        self.isCharging = isCharging
    }

    public var formattedBatteryPercent: String {
        if batteryLevel < 0 { return "Unknown" }
        return "\(Int(batteryLevel * 100))%"
    }
}

import Foundation

/// Represents a Gaming Session recorded in GCOOL.
///
/// Technical Truth:
/// Standard iOS applications do not execute continuously in the background while a user plays a game.
/// GCOOL persists accurate timestamps upon session start, departure, and return, calculating elapsed session duration
/// from absolute wall-clock time rather than fabricating synthetic continuous telemetry while suspended.
public struct GamingSession: Identifiable, Codable, Equatable {
    public let id: UUID
    public var gameId: UUID?
    public var gameName: String
    public var startTime: Date
    public var endTime: Date?
    public var isCompleted: Bool
    public var startThermalLevel: ThermalLevel
    public var endThermalLevel: ThermalLevel?
    public var highestThermalLevel: ThermalLevel
    public var startBatteryLevel: Float
    public var endBatteryLevel: Float?
    public var distractionShieldAttempted: Bool
    public var sessionNotes: String

    public init(
        id: UUID = UUID(),
        gameId: UUID? = nil,
        gameName: String,
        startTime: Date = Date(),
        endTime: Date? = nil,
        isCompleted: Bool = false,
        startThermalLevel: ThermalLevel = .nominal,
        endThermalLevel: ThermalLevel? = nil,
        highestThermalLevel: ThermalLevel = .nominal,
        startBatteryLevel: Float = -1.0,
        endBatteryLevel: Float? = nil,
        distractionShieldAttempted: Bool = false,
        sessionNotes: String = ""
    ) {
        self.id = id
        self.gameId = gameId
        self.gameName = gameName
        self.startTime = startTime
        self.endTime = endTime
        self.isCompleted = isCompleted
        self.startThermalLevel = startThermalLevel
        self.endThermalLevel = endThermalLevel
        self.highestThermalLevel = highestThermalLevel
        self.startBatteryLevel = startBatteryLevel
        self.endBatteryLevel = endBatteryLevel
        self.distractionShieldAttempted = distractionShieldAttempted
        self.sessionNotes = sessionNotes
    }

    /// Calculates real wall-clock elapsed seconds up to now (if active) or endTime (if completed).
    public func elapsedSeconds(at referenceDate: Date = Date()) -> TimeInterval {
        let terminal = endTime ?? referenceDate
        let elapsed = terminal.timeIntervalSince(startTime)
        return max(0, elapsed)
    }

    /// Human-friendly duration string (e.g. "45m 12s" or "1h 15m").
    public func formattedDuration(at referenceDate: Date = Date()) -> String {
        let total = Int(elapsedSeconds(at: referenceDate))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60

        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else {
            return String(format: "%dm %02ds", minutes, seconds)
        }
    }
}

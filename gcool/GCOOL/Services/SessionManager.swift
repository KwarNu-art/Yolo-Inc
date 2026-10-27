import Foundation
import Combine
import UIKit

/// Manages active and historical gaming sessions with accurate wall-clock time tracking.
public class SessionManager: ObservableObject {
    public static let shared = SessionManager()

    @Published public private(set) var activeSession: GamingSession?
    @Published public private(set) var sessionHistory: [GamingSession] = []
    @Published public private(set) var currentElapsedDurationString: String = "00m 00s"

    private let storageFileName = "gcool_sessions.json"
    private var tickerTimer: Timer?

    public init() {
        loadHistory()
        loadActiveSession()
        startTicker()
    }

    deinit {
        tickerTimer?.invalidate()
    }

    // MARK: - Active Session Lifecycle

    /// Starts a session for the specified game.
    @discardableResult
    public func startSession(for game: GameItem, initialThermal: ThermalLevel = .nominal, initialBattery: Float = -1.0) -> GamingSession {
        // End any existing dangling active session first
        if let existing = activeSession {
            endSession(finalThermal: initialThermal, finalBattery: initialBattery, notes: "Auto-ended before starting new session.")
        }

        let newSession = GamingSession(
            gameId: game.id,
            gameName: game.name,
            startTime: Date(),
            isCompleted: false,
            startThermalLevel: initialThermal,
            highestThermalLevel: initialThermal,
            startBatteryLevel: initialBattery,
            distractionShieldAttempted: false,
            sessionNotes: ""
        )

        self.activeSession = newSession
        saveActiveSession()
        updateElapsedDisplay()
        return newSession
    }

    /// Ends the current active gaming session.
    @discardableResult
    public func endSession(finalThermal: ThermalLevel = .nominal, finalBattery: Float? = nil, notes: String? = nil) -> GamingSession? {
        guard var session = activeSession else { return nil }

        session.endTime = Date()
        session.isCompleted = true
        session.endThermalLevel = finalThermal
        session.endBatteryLevel = finalBattery
        if let notes = notes, !notes.isEmpty {
            session.sessionNotes = notes
        }

        // Add to history
        sessionHistory.insert(session, at: 0)
        saveHistory()

        // Clear active session
        self.activeSession = nil
        clearActiveSessionStore()
        updateElapsedDisplay()
        return session
    }

    /// Records a thermal transition during an active session if it exceeds previously observed levels.
    public func recordThermalObservation(_ level: ThermalLevel) {
        guard var session = activeSession else { return }
        if levelRank(level) > levelRank(session.highestThermalLevel) {
            session.highestThermalLevel = level
            self.activeSession = session
            saveActiveSession()
        }
    }

    private func levelRank(_ level: ThermalLevel) -> Int {
        switch level {
        case .nominal: return 0
        case .fair: return 1
        case .serious: return 2
        case .critical: return 3
        case .unknown: return -1
        }
    }

    // MARK: - Duration Timer

    private func startTicker() {
        tickerTimer?.invalidate()
        tickerTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateElapsedDisplay()
        }
    }

    private func updateElapsedDisplay() {
        if let active = activeSession {
            self.currentElapsedDurationString = active.formattedDuration()
        } else {
            self.currentElapsedDurationString = "00m 00s"
        }
    }

    // MARK: - Persistence

    private var historyFileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(storageFileName)
    }

    private var activeSessionFileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("gcool_active_session.json")
    }

    public func saveHistory() {
        do {
            let data = try JSONEncoder().encode(sessionHistory)
            try data.write(to: historyFileURL, options: .atomic)
        } catch {
            print("[GCOOL] Failed to save session history: \(error.localizedDescription)")
        }
    }

    private func loadHistory() {
        guard FileManager.default.fileExists(atPath: historyFileURL.path) else { return }
        do {
            let data = try Data(contentsOf: historyFileURL)
            self.sessionHistory = try JSONDecoder().decode([GamingSession].self, from: data)
        } catch {
            print("[GCOOL] Failed to load session history: \(error.localizedDescription)")
        }
    }

    public func saveActiveSession() {
        guard let session = activeSession else {
            clearActiveSessionStore()
            return
        }
        do {
            let data = try JSONEncoder().encode(session)
            try data.write(to: activeSessionFileURL, options: .atomic)
        } catch {
            print("[GCOOL] Failed to save active session: \(error.localizedDescription)")
        }
    }

    private func loadActiveSession() {
        guard FileManager.default.fileExists(atPath: activeSessionFileURL.path) else { return }
        do {
            let data = try Data(contentsOf: activeSessionFileURL)
            self.activeSession = try JSONDecoder().decode(GamingSession.self, from: data)
        } catch {
            print("[GCOOL] Failed to load active session: \(error.localizedDescription)")
        }
    }

    private func clearActiveSessionStore() {
        try? FileManager.default.removeItem(at: activeSessionFileURL)
    }

    /// Clears all historical session logs.
    public func clearAllHistory() {
        sessionHistory.removeAll()
        saveHistory()
    }
}

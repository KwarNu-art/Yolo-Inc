import XCTest
@testable import GCOOL

class SessionManagerTests: XCTestCase {
    var sessionManager: SessionManager!

    override func setUp() {
        super.setUp()
        sessionManager = SessionManager()
        sessionManager.clearAllHistory()
    }

    override func tearDown() {
        sessionManager.clearAllHistory()
        super.tearDown()
    }

    func testStartAndEndSession() {
        let game = GameItem(name: "Test Game", category: "Action")
        let session = sessionManager.startSession(for: game, initialThermal: .nominal, initialBattery: 0.85)

        XCTAssertNotNil(sessionManager.activeSession)
        XCTAssertEqual(sessionManager.activeSession?.gameName, "Test Game")
        XCTAssertEqual(sessionManager.activeSession?.startThermalLevel, .nominal)
        XCTAssertEqual(sessionManager.activeSession?.startBatteryLevel, 0.85)

        let ended = sessionManager.endSession(finalThermal: .fair, finalBattery: 0.80, notes: "Good test")
        XCTAssertNotNil(ended)
        XCTAssertTrue(ended?.isCompleted ?? false)
        XCTAssertEqual(ended?.endThermalLevel, .fair)
        XCTAssertEqual(ended?.sessionNotes, "Good test")
        XCTAssertNil(sessionManager.activeSession)
        XCTAssertEqual(sessionManager.sessionHistory.count, 1)
    }

    func testElapsedDurationCalculation() {
        let startTime = Date(timeIntervalSince1970: 1000)
        let session = GamingSession(
            gameName: "Duration Test",
            startTime: startTime,
            isCompleted: false
        )

        // 45 seconds later
        let ref45s = Date(timeIntervalSince1970: 1045)
        XCTAssertEqual(session.elapsedSeconds(at: ref45s), 45.0)
        XCTAssertEqual(session.formattedDuration(at: ref45s), "0m 45s")

        // 1 hour 15 minutes 30 seconds later
        let refLong = Date(timeIntervalSince1970: 1000 + 3600 + (15 * 60) + 30)
        XCTAssertEqual(session.formattedDuration(at: refLong), "1h 15m")
    }

    func testThermalObservationTracking() {
        let game = GameItem(name: "Thermal Test Game")
        sessionManager.startSession(for: game, initialThermal: .nominal)

        XCTAssertEqual(sessionManager.activeSession?.highestThermalLevel, .nominal)

        // Elevated to Fair
        sessionManager.recordThermalObservation(.fair)
        XCTAssertEqual(sessionManager.activeSession?.highestThermalLevel, .fair)

        // Elevated to Serious
        sessionManager.recordThermalObservation(.serious)
        XCTAssertEqual(sessionManager.activeSession?.highestThermalLevel, .serious)

        // Dropped to Nominal (highest should remain Serious)
        sessionManager.recordThermalObservation(.nominal)
        XCTAssertEqual(sessionManager.activeSession?.highestThermalLevel, .serious)
    }

    func testClearAllHistory() {
        let game = GameItem(name: "History Game")
        sessionManager.startSession(for: game)
        sessionManager.endSession()

        XCTAssertEqual(sessionManager.sessionHistory.count, 1)
        sessionManager.clearAllHistory()
        XCTAssertEqual(sessionManager.sessionHistory.count, 0)
    }
}

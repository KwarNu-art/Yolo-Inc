import XCTest
@testable import GCOOL

class FeasibilityTests: XCTestCase {

    func testFourLockMeaningsExplicitlyDistinguished() {
        let meanings = ScreenTimeFeasibility.lockMeanings
        XCTAssertEqual(meanings.count, 4)

        // 1. In-app game pinning is supported by GCOOL
        XCTAssertEqual(meanings[0].title, "1. In-App Game Pinning")
        XCTAssertTrue(meanings[0].canGCOOLDoIt)

        // 2. Personal Screen time app blocking is restricted on iOS 15
        XCTAssertEqual(meanings[1].title, "2. Screen Time Distraction Restriction")
        XCTAssertFalse(meanings[1].canGCOOLDoIt)

        // 3. Keep game in RAM / prevent Jetsam OS kill is impossible in sandbox
        XCTAssertEqual(meanings[2].title, "3. Keep Game in RAM / Prevent OS Termination")
        XCTAssertFalse(meanings[2].canGCOOLDoIt)

        // 4. Single-app device lockdown is handled via Apple Guided Access
        XCTAssertEqual(meanings[3].title, "4. Single-App Device Lockdown")
        XCTAssertFalse(meanings[3].canGCOOLDoIt)
    }

    func testScreenTimeFeasibilityStatus() {
        let status = ScreenTimeFeasibility.individualAuthorizationStatus
        // On simulator / macOS host, check that the status resolves properly without crashing
        switch status {
        case .available, .restrictedByOSVersion, .missingEntitlement, .unsupportedBySandbox:
            XCTAssertTrue(true)
        }
    }
}

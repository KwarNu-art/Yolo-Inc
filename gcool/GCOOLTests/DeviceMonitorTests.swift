import XCTest
@testable import GCOOL

class DeviceMonitorTests: XCTestCase {

    func testThermalLevelMapping() {
        XCTAssertEqual(ThermalLevel(from: .nominal), .nominal)
        XCTAssertEqual(ThermalLevel(from: .fair), .fair)
        XCTAssertEqual(ThermalLevel(from: .serious), .serious)
        XCTAssertEqual(ThermalLevel(from: .critical), .critical)
    }

    func testThermalLevelTitlesAndBadges() {
        XCTAssertEqual(ThermalLevel.nominal.badgeText, "COOL")
        XCTAssertEqual(ThermalLevel.fair.badgeText, "WARM")
        XCTAssertEqual(ThermalLevel.serious.badgeText, "HOT")
        XCTAssertEqual(ThermalLevel.critical.badgeText, "ALERT")
    }

    func testThermalSnapshotBatteryFormatting() {
        let snap1 = ThermalSnapshot(level: .nominal, batteryLevel: 0.85, isLowPowerMode: false, isCharging: false)
        XCTAssertEqual(snap1.formattedBatteryPercent, "85%")

        let snapUnknown = ThermalSnapshot(level: .nominal, batteryLevel: -1.0, isLowPowerMode: false, isCharging: false)
        XCTAssertEqual(snapUnknown.formattedBatteryPercent, "Unknown")
    }

    func testThermalExplanationsAvoidDangerousCooling() {
        // Assert that critical recommendation explicitly warns against freezers
        let criticalRec = ThermalLevel.critical.recommendedAction
        XCTAssertTrue(criticalRec.contains("freezer") || criticalRec.contains("ice"))
    }
}

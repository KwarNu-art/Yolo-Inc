import Foundation
import UIKit
import Combine

/// Observable service providing real-time hardware telemetry from public iOS APIs.
/// Technical honesty:
/// - ProcessInfo.ThermalState is nominal, fair, serious, or critical. (No raw Celsius).
/// - Battery level is 0.0 to 1.0 (or -1.0 if running on simulator / unknown).
/// - Low Power Mode is observed via NSNotificationCenter.
public class DeviceMonitorService: ObservableObject {
    public static let shared = DeviceMonitorService()

    @Published public private(set) var currentThermalLevel: ThermalLevel = .nominal
    @Published public private(set) var batteryLevel: Float = -1.0
    @Published public private(set) var isCharging: Bool = false
    @Published public private(set) var isLowPowerMode: Bool = false
    @Published public private(set) var deviceModelName: String = ""
    @Published public private(set) var systemVersion: String = ""
    @Published public private(set) var thermalHistory: [ThermalSnapshot] = []

    private var cancellables = Set<AnyCancellable>()

    public init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        self.deviceModelName = resolveDeviceModelName()
        self.systemVersion = UIDevice.current.systemVersion
        refreshSnapshot()
        registerObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func refreshSnapshot() {
        // Query ProcessInfo thermal state
        let rawThermal = ProcessInfo.processInfo.thermalState
        let level = ThermalLevel(from: rawThermal)
        self.currentThermalLevel = level

        // Query Battery
        let rawBattery = UIDevice.current.batteryLevel
        self.batteryLevel = rawBattery >= 0 ? rawBattery : -1.0
        let state = UIDevice.current.batteryState
        self.isCharging = (state == .charging || state == .full)

        // Low Power Mode
        self.isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled

        // Record snapshot in local memory buffer (max 30 snapshots)
        let snapshot = ThermalSnapshot(
            level: level,
            batteryLevel: self.batteryLevel,
            isLowPowerMode: self.isLowPowerMode,
            isCharging: self.isCharging
        )
        self.thermalHistory.insert(snapshot, at: 0)
        if self.thermalHistory.count > 30 {
            self.thermalHistory.removeLast()
        }
    }

    private func registerObservers() {
        let center = NotificationCenter.default

        // Thermal State changes
        center.addObserver(
            self,
            selector: #selector(handleThermalNotification),
            name: ProcessInfo.thermalStateDidChangeNotification,
            object: nil
        )

        // Battery level changes
        center.addObserver(
            self,
            selector: #selector(handleBatteryNotification),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )

        // Battery state changes (plugged in / unplugged)
        center.addObserver(
            self,
            selector: #selector(handleBatteryNotification),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )

        // Low Power Mode changes
        center.addObserver(
            self,
            selector: #selector(handleLowPowerNotification),
            name: NSNotification.Name.NSProcessInfoPowerStateDidChange,
            object: nil
        )

        // Foreground transition
        center.addObserver(
            self,
            selector: #selector(handleForegroundNotification),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func handleThermalNotification() {
        DispatchQueue.main.async {
            self.refreshSnapshot()
        }
    }

    @objc private func handleBatteryNotification() {
        DispatchQueue.main.async {
            self.refreshSnapshot()
        }
    }

    @objc private func handleLowPowerNotification() {
        DispatchQueue.main.async {
            self.refreshSnapshot()
        }
    }

    @objc private func handleForegroundNotification() {
        DispatchQueue.main.async {
            self.refreshSnapshot()
        }
    }

    private func resolveDeviceModelName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch identifier {
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "x86_64", "arm64": return "iPhone 7 Plus Simulator"
        default:
            return identifier.isEmpty ? "iPhone" : identifier
        }
    }
}

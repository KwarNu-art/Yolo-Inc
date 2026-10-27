import SwiftUI

/// Optimized, battery-conscious seasonal snowfall particle overlay.
/// Technical care for iPhone 7 Plus:
/// - Automatically disables itself if Accessibility -> Reduce Motion is enabled.
/// - Automatically pauses when Low Power Mode is active to prevent energy drain.
/// - Stops rendering when app is inactive or in the background.
public struct SnowfallView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @ObservedObject var deviceMonitor = DeviceMonitorService.shared

    private struct Snowflake: Identifiable {
        let id: Int
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var speed: CGFloat
        var opacity: Double
    }

    @State private var flakes: [Snowflake] = (0..<24).map { i in
        Snowflake(
            id: i,
            x: CGFloat.random(in: 0...414), // Default iPhone 7 Plus screen width points
            y: CGFloat.random(in: -50...736),
            size: CGFloat.random(in: 2...4.5),
            speed: CGFloat.random(in: 25...55),
            opacity: Double.random(in: 0.25...0.65)
        )
    }

    public init() {}

    public var body: some View {
        if reduceMotion || deviceMonitor.isLowPowerMode {
            // Disabled when user requested reduced motion or when preserving battery
            EmptyView()
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                Canvas { context, size in
                    for flake in flakes {
                        let rect = CGRect(
                            x: flake.x.truncatingRemainder(dividingBy: size.width),
                            y: flake.y.truncatingRemainder(dividingBy: size.height),
                            width: flake.size,
                            height: flake.size
                        )
                        context.opacity = flake.opacity
                        context.fill(Path(ellipseIn: rect), with: .color(GlacierTheme.frostCyan))
                    }
                }
                .onChange(of: timeline.date) { _ in
                    updatePositions()
                }
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()
        }
    }

    private func updatePositions() {
        for i in 0..<flakes.count {
            flakes[i].y += flakes[i].speed * 0.033
            flakes[i].x += sin(flakes[i].y * 0.02) * 0.4
            if flakes[i].y > 800 {
                flakes[i].y = -10
                flakes[i].x = CGFloat.random(in: 0...414)
            }
        }
    }
}

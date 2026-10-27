import SwiftUI

/// Frosted crystal glassmorphic container card.
public struct GlacierCard<Content: View>: View {
    public let content: Content
    public let cornerRadius: CGFloat
    public let borderColor: Color

    public init(
        cornerRadius: CGFloat = 18,
        borderColor: Color = GlacierTheme.cardBorder,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.content = content()
    }

    public var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(GlacierTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(borderColor, lineWidth: 1.0)
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 6)
            )
    }
}

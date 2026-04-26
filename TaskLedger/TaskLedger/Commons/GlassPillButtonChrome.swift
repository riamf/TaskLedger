import SwiftUI

private struct GlassPillButtonChromeModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    let accentColor: Color
    let cornerRadius: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat

    func body(content: Content) -> some View {
        content
            .foregroundStyle(colorScheme == .light ? .black : .white)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .light ? 0.6 : 0.3),
                                Color.white.opacity(colorScheme == .light ? 0.2 : 0.05),
                                accentColor.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(colorScheme == .light ? 0.08 : 0.2), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func glassPillButtonChrome(
        accentColor: Color = .blue,
        cornerRadius: CGFloat = 20,
        horizontalPadding: CGFloat = 16,
        verticalPadding: CGFloat = 8
    ) -> some View {
        modifier(
            GlassPillButtonChromeModifier(
                accentColor: accentColor,
                cornerRadius: cornerRadius,
                horizontalPadding: horizontalPadding,
                verticalPadding: verticalPadding
            )
        )
    }
}

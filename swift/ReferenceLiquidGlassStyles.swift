import SwiftUI
import UIKit

// Directly adapted from GlobalRefresh-PiP's verified button styles.
// Original project: https://github.com/CaiWanFeng/PiP
// Reference project: https://github.com/Yoroin/GlobalRefresh-PiP

struct PiPReferenceLiquidGlassButtonStyle: ButtonStyle {
    var radius: CGFloat = 24
    var tint: Color = Color(UIColor.secondarySystemBackground)

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        return configuration.label
            .background(glassBackground(isPressed: configuration.isPressed, shape: shape))
            .overlay(
                shape.strokeBorder(
                    referenceAdaptiveGlassStrokeColor.opacity(configuration.isPressed ? 1 : 0.86),
                    lineWidth: 1
                )
            )
            .clipShape(shape)
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .brightness(configuration.isPressed ? 0.025 : 0)
            .shadow(
                color: Color.black.opacity(configuration.isPressed ? 0.08 : 0.14),
                radius: configuration.isPressed ? 8 : 16,
                x: 0,
                y: configuration.isPressed ? 4 : 10
            )
            .animation(.spring(response: 0.22, dampingFraction: 0.78), value: configuration.isPressed)
    }

    @ViewBuilder
    private func glassBackground(isPressed: Bool, shape: RoundedRectangle) -> some View {
        if #available(iOS 26.0, *) {
            shape
                .fill(tint.opacity(isPressed ? 0.42 : 0.22))
                .glassEffect(.regular.interactive(), in: shape)
        } else {
            shape
                .fill(.ultraThinMaterial)
                .overlay(shape.fill(tint.opacity(isPressed ? 0.38 : 0.22)))
        }
    }
}

struct PiPReferenceGlassCapsuleButtonStyle: ButtonStyle {
    var tint: Color = Color(UIColor.secondarySystemBackground)

    func makeBody(configuration: Configuration) -> some View {
        let shape = Capsule()

        return configuration.label
            .background(glassBackground(isPressed: configuration.isPressed, shape: shape))
            .overlay(
                shape.strokeBorder(
                    referenceLegacyStrokeColor(isPressed: configuration.isPressed),
                    lineWidth: 1
                )
            )
            .clipShape(shape)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.78), value: configuration.isPressed)
    }

    @ViewBuilder
    private func glassBackground(isPressed: Bool, shape: Capsule) -> some View {
        if #available(iOS 26.0, *) {
            shape
                .fill(tint.opacity(isPressed ? 0.4 : 0.22))
                .glassEffect(.regular.interactive(), in: shape)
        } else {
            shape
                .fill(.regularMaterial)
                .overlay(shape.fill(tint.opacity(isPressed ? 0.54 : 0.38)))
        }
    }
}

private func referenceLegacyStrokeColor(isPressed: Bool) -> Color {
    if #available(iOS 26.0, *) {
        return Color.white.opacity(isPressed ? 0.34 : 0.22)
    }
    return Color(UIColor.separator).opacity(isPressed ? 1 : 0.86)
}

private var referenceAdaptiveGlassStrokeColor: Color {
    if #available(iOS 26.0, *) {
        return Color.white.opacity(0.22)
    }
    return Color(UIColor.separator).opacity(0.62)
}

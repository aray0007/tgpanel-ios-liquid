
import SwiftUI
import UIKit

// MARK: - Compiler Compatibility Shims
struct GlassEffectStyle {
    static var regular: GlassEffectStyle { GlassEffectStyle() }
    func interactive() -> GlassEffectStyle { self }
}

extension View {
    func glassEffect(_ style: GlassEffectStyle = .regular, in shape: some Shape = RoundedRectangle(cornerRadius: 18, style: .continuous)) -> some View {
        self
    }
    func glassEffectID(_ id: AnyHashable, in namespace: Namespace.ID) -> some View {
        self
    }
}

struct GlassEffectContainer<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    init(spacing: CGFloat = 10, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    var body: some View {
        content
    }
}

// Adapted from GlobalRefresh-PiP's Liquid Glass UI patterns.
// Attribution: CaiWanFeng (original PiP) and Yoroin (GlobalRefresh-PiP).
// https://github.com/Yoroin/GlobalRefresh-PiP

enum GlassTheme {
    static let background = Color(UIColor.systemBackground)
    static let groupedBackground = Color(UIColor.secondarySystemBackground)
    static let text = Color(UIColor.label)
    static let secondary = Color(UIColor.secondaryLabel)
    static let teal = Color(red: 0.22, green: 0.80, blue: 0.72)
    static let tealStrong = Color(red: 0.10, green: 0.68, blue: 0.60)
    static let amber = Color(red: 0.92, green: 0.63, blue: 0.20)
    static let red = Color(red: 0.86, green: 0.25, blue: 0.29)
    static let glassEdge = Color.white.opacity(0.22)
    static let legacyEdge = Color(UIColor.separator).opacity(0.62)
}

struct LiquidGlassBackdrop: View {
    var body: some View {
        ZStack {
            GlassTheme.background
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.07, blue: 0.10),
                    Color(red: 0.03, green: 0.025, blue: 0.05),
                    Color(red: 0.08, green: 0.035, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.82)
            LinearGradient(
                colors: [GlassTheme.teal.opacity(0.10), .clear, Color.indigo.opacity(0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.screen)
        }
        .ignoresSafeArea()
    }
}

struct GlassSurface<Content: View>: View {
    let radius: CGFloat
    let tint: Color
    let contentPadding: CGFloat
    let content: Content

    init(radius: CGFloat = 22, tint: Color = GlassTheme.groupedBackground, contentPadding: CGFloat = 0, @ViewBuilder content: () -> Content) {
        self.radius = radius
        self.tint = tint
        self.contentPadding = contentPadding
        self.content = content()
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        content
            .padding(contentPadding)
            .background {
                if #available(iOS 26.0, *) {
                    shape
                        .fill(tint.opacity(0.22))
                        .glassEffect(.regular.interactive(), in: shape)
                } else {
                    shape
                        .fill(.ultraThinMaterial)
                        .overlay(shape.fill(tint.opacity(0.38)))
                }
            }
            .overlay(shape.strokeBorder(GlassTheme.glassEdge, lineWidth: 1))
            .clipShape(shape)
            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 7)
    }
}

struct GlassCard<Content: View>: View {
    let radius: CGFloat
    let tint: Color
    let content: Content

    init(radius: CGFloat = 22, tint: Color = GlassTheme.groupedBackground, @ViewBuilder content: () -> Content) {
        self.radius = radius
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        content
            .padding(16)
            .background(glassBackground(shape: shape))
            .overlay(shape.strokeBorder(GlassTheme.glassEdge, lineWidth: 1))
            .clipShape(shape)
            .shadow(color: .black.opacity(0.16), radius: 16, x: 0, y: 10)
    }

    @ViewBuilder
    private func glassBackground(shape: RoundedRectangle) -> some View {
        if #available(iOS 26.0, *) {
            shape
                .fill(tint.opacity(0.22))
                .glassEffect(.regular.interactive(), in: shape)
        } else {
            shape
                .fill(.ultraThinMaterial)
                .overlay(shape.fill(tint.opacity(0.38)))
        }
    }
}

struct GlassCapsule<Content: View>: View {
    let tint: Color
    let content: Content

    init(tint: Color = GlassTheme.groupedBackground, @ViewBuilder content: () -> Content) {
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        let shape = Capsule()
        content
            .padding(.horizontal, 11)
            .frame(minHeight: 34)
            .background {
                if #available(iOS 26.0, *) {
                    shape
                        .fill(tint.opacity(0.22))
                        .glassEffect(.regular.interactive(), in: shape)
                } else {
                    shape
                        .fill(.ultraThinMaterial)
                        .overlay(shape.fill(tint.opacity(0.38)))
                }
            }
            .overlay(shape.strokeBorder(GlassTheme.glassEdge, lineWidth: 1))
            .clipShape(shape)
    }
}

struct LiquidGlassButtonStyle: ButtonStyle {
    var tint: Color = GlassTheme.groupedBackground
    var radius: CGFloat = 22

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        configuration.label
            .background {
                if #available(iOS 26.0, *) {
                    shape
                        .fill(tint.opacity(configuration.isPressed ? 0.42 : 0.22))
                        .glassEffect(.regular.interactive(), in: shape)
                } else {
                    shape
                        .fill(.ultraThinMaterial)
                        .overlay(shape.fill(tint.opacity(configuration.isPressed ? 0.38 : 0.22)))
                }
            }
            .overlay(shape.strokeBorder(GlassTheme.glassEdge.opacity(configuration.isPressed ? 1 : 0.86), lineWidth: 1))
            .clipShape(shape)
            .scaleEffect(configuration.isPressed ? 0.965 : 1)
            .shadow(color: tint.opacity(configuration.isPressed ? 0.08 : 0.16), radius: configuration.isPressed ? 7 : 14, x: 0, y: configuration.isPressed ? 3 : 8)
            .animation(.spring(response: 0.22, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

struct LiquidGlassCapsuleButtonStyle: ButtonStyle {
    var tint: Color = GlassTheme.groupedBackground

    func makeBody(configuration: Configuration) -> some View {
        let shape = Capsule()
        configuration.label
            .background {
                if #available(iOS 26.0, *) {
                    shape
                        .fill(tint.opacity(configuration.isPressed ? 0.40 : 0.22))
                        .glassEffect(.regular.interactive(), in: shape)
                } else {
                    shape
                        .fill(.ultraThinMaterial)
                        .overlay(shape.fill(tint.opacity(configuration.isPressed ? 0.54 : 0.38)))
                }
            }
            .overlay(shape.strokeBorder(GlassTheme.glassEdge.opacity(configuration.isPressed ? 1 : 0.86), lineWidth: 1))
            .clipShape(shape)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

struct LiquidGlassTabItemStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 48)
            .background {
                if #available(iOS 26.0, *) {
                    shape
                        .fill((isSelected ? GlassTheme.teal : GlassTheme.groupedBackground).opacity(configuration.isPressed ? 0.34 : (isSelected ? 0.18 : 0.10)))
                        .glassEffect(.regular.interactive(), in: shape)
                } else {
                    shape
                        .fill(.ultraThinMaterial)
                        .overlay(shape.fill((isSelected ? GlassTheme.teal : GlassTheme.groupedBackground).opacity(isSelected ? 0.18 : 0.10)))
                }
            }
            .overlay(shape.strokeBorder(GlassTheme.glassEdge.opacity(isSelected ? 1 : 0.72), lineWidth: 1))
            .clipShape(shape)
            .scaleEffect(configuration.isPressed ? 0.965 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

struct Eyebrow: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .tracking(1.5)
            .foregroundStyle(GlassTheme.secondary)
    }
}

struct StatusBadge: View {
    let status: AccountStatus

    private var tint: Color {
        switch status {
        case .online: GlassTheme.teal
        case .offline: GlassTheme.amber
        case .warning, .unauthorized: GlassTheme.red
        }
    }

    var body: some View {
        GlassCapsule(tint: tint) {
            Label(status.title, systemImage: "circle.fill")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(tint)
                .labelStyle(.titleAndIcon)
                .symbolRenderingMode(.palette)
                .foregroundStyle(tint, tint)
        }
    }
}

struct AccountAvatar: View {
    let initial: String

    var body: some View {
        Text(initial)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(GlassTheme.teal)
            .frame(width: 42, height: 42)
            .background {
                if #available(iOS 26.0, *) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(GlassTheme.teal.opacity(0.12))
                        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 14))
                } else {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(GlassTheme.teal.opacity(0.12))
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(GlassTheme.glassEdge, lineWidth: 1)
            }
    }
}

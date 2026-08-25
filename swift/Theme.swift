import SwiftUI

enum GlassTheme {
    static let background = Color(red: 0.02, green: 0.025, blue: 0.027)
    static let text = Color(red: 0.95, green: 0.97, blue: 0.965)
    static let secondary = Color(red: 0.53, green: 0.58, blue: 0.57)
    static let teal = Color(red: 0.55, green: 0.90, blue: 0.84)
    static let tealStrong = Color(red: 0.25, green: 0.78, blue: 0.70)
    static let amber = Color(red: 0.95, green: 0.78, blue: 0.48)
    static let red = Color(red: 0.94, green: 0.57, blue: 0.55)
}

enum GlassStyle {
    case regular
}

// MARK: - Liquid Glass UI Modifiers & Extensions
extension View {
    func glassEffect(_ style: GlassStyle = .regular, in shape: some Shape = RoundedRectangle(cornerRadius: 18, style: .continuous)) -> some View {
        self
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.04))
            .clipShape(shape)
            .overlay(
                shape.stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.45),
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            )
            .shadow(color: Color.black.opacity(0.35), radius: 10, y: 5)
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

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(configuration.isPressed ? 0.15 : 0.05))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GlassButtonStyle {
    static var glass: GlassButtonStyle { GlassButtonStyle() }
}

// MARK: - Components
struct GlassCard<Content: View>: View {
    let radius: CGFloat
    let content: Content

    init(radius: CGFloat = 22, @ViewBuilder content: () -> Content) {
        self.radius = radius
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
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
        Label(status.title, systemImage: "circle.fill")
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .labelStyle(.titleAndIcon)
            .symbolRenderingMode(.palette)
            .foregroundStyle(tint, tint)
    }
}

struct AccountAvatar: View {
    let initial: String

    var body: some View {
        Text(initial)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(GlassTheme.teal)
            .frame(width: 42, height: 42)
            .background(GlassTheme.teal.opacity(0.13), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(GlassTheme.teal.opacity(0.22), lineWidth: 1)
            }
    }
}

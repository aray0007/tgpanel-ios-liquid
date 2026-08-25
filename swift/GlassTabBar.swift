import SwiftUI

struct GlassTabBar: View {
    @Binding var selection: Int

    var body: some View {
        GlassEffectContainer(spacing: 10) {
            HStack(spacing: 6) {
                tab(index: 0, title: "Overview", symbol: "rectangle.grid.1x2")
                tab(index: 1, title: "Accounts", symbol: "person.2")
                tab(index: 2, title: "Settings", symbol: "ellipsis")
            }
            .padding(6)
            .background {
                if #available(iOS 26.0, *) {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(GlassTheme.groupedBackground.opacity(0.18))
                        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 25))
                } else {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .strokeBorder(GlassTheme.glassEdge, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)
        }
    }

    private func tab(index: Int, title: String, symbol: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.26, dampingFraction: 0.78)) {
                selection = index
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(selection == index ? GlassTheme.teal : GlassTheme.secondary)
        }
        .buttonStyle(PiPReferenceLiquidGlassButtonStyle(radius: 18, tint: selection == index ? GlassTheme.teal : GlassTheme.groupedBackground))
        .glassEffectID(index, in: tabNamespace)
    }

    @Namespace private var tabNamespace
}

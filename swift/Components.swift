import SwiftUI

struct TopBar: View {
    let onSettings: () -> Void

    var body: some View {
        HStack {
            HStack(spacing: 12) {
                HStack(alignment: .bottom, spacing: 3) {
                    Capsule().fill(GlassTheme.teal.opacity(0.55)).frame(width: 5, height: 12)
                    Capsule().fill(GlassTheme.teal).frame(width: 5, height: 19)
                    Capsule().fill(GlassTheme.teal.opacity(0.78)).frame(width: 5, height: 15)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Eyebrow(text: "TELEGRAM CONTROL")
                    Text("TG Panel")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                }
            }
            Spacer()
            Button(action: onSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: 42, height: 42)
            }
            .buttonStyle(PiPReferenceLiquidGlassButtonStyle(radius: 15, tint: GlassTheme.groupedBackground))
            .accessibilityLabel("Settings")
        }
    }
}

struct ConnectionPill: View {
    let syncTime: String
    let onRefresh: () -> Void

    var body: some View {
        Button(action: onRefresh) {
            HStack(spacing: 7) {
                Circle().fill(GlassTheme.tealStrong).frame(width: 7, height: 7)
                Text("VPS connected")
                Image(systemName: "arrow.clockwise")
            }
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundStyle(GlassTheme.teal)
        }
        .buttonStyle(PiPReferenceGlassCapsuleButtonStyle(tint: GlassTheme.teal))
        .accessibilityLabel("Refresh demo data")
    }
}

struct MetricCard: View {
    let title: String
    let number: String
    let detail: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                Image(systemName: icon).foregroundStyle(tint)
            }
            Spacer(minLength: 4)
            Text(title).font(.system(size: 11, weight: .medium, design: .rounded)).foregroundStyle(GlassTheme.secondary)
            Text(number).font(.system(size: 27, weight: .semibold, design: .rounded)).foregroundStyle(GlassTheme.text)
            Text(detail).font(.system(size: 9, weight: .regular, design: .rounded)).foregroundStyle(GlassTheme.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .padding(14)
        .background {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: 19, style: .continuous)
                    .fill(tint.opacity(0.10))
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 19))
            } else {
                RoundedRectangle(cornerRadius: 19, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(tint.opacity(0.10))
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 19, style: .continuous)
                .strokeBorder(GlassTheme.glassEdge, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
        .shadow(color: tint.opacity(0.12), radius: 12, x: 0, y: 7)
    }
}

struct ActivityRow: View {
    let item: ActivityItem

    private var tint: Color {
        switch item.tone {
        case .success: GlassTheme.teal
        case .neutral: GlassTheme.secondary
        case .warning: GlassTheme.amber
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.symbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.12), in: .rect(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title).font(.system(size: 12, weight: .semibold, design: .rounded))
                Text(item.detail).font(.system(size: 10, design: .rounded)).foregroundStyle(GlassTheme.secondary)
            }
            Spacer()
            Text(item.time).font(.system(size: 10, design: .rounded)).foregroundStyle(GlassTheme.secondary.opacity(0.65))
        }
        .padding(.vertical, 9)
    }
}

struct AccountRow: View {
    let account: Account
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                AccountAvatar(initial: account.initial)
                VStack(alignment: .leading, spacing: 5) {
                    Text(account.phone).font(.system(size: 13, weight: .semibold, design: .rounded))
                    Text("\(account.remark) · \(account.lastActivity)")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(GlassTheme.secondary)
                }
                Spacer(minLength: 4)
                VStack(alignment: .trailing, spacing: 7) {
                    StatusBadge(status: account.status)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(GlassTheme.secondary)
                }
            }
            .padding(12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PiPReferenceLiquidGlassButtonStyle(radius: 18, tint: GlassTheme.groupedBackground))
    }
}

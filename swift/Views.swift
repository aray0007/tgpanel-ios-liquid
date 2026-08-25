import SwiftUI

struct RootTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            LiquidGlassBackdrop()
            Group {
                switch selectedTab {
                case 0:
                    OverviewView(selectedTab: $selectedTab)
                case 1:
                    AccountsView()
                default:
                    SettingsView()
                }
            }
            .id(selectedTab)
            .transition(.opacity)
        }
        .animation(.easeOut(duration: 0.22), value: selectedTab)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            GlassTabBar(selection: $selectedTab)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
        }
        .preferredColorScheme(.dark)
    }
}

struct OverviewView: View {
    @Binding var selectedTab: Int
    @State private var syncTime = "just now"
    private let accounts = DemoData.accounts

    private var overviewTitle: some View {
        VStack(alignment: .leading, spacing: 8) {
            Eyebrow(text: "OVERVIEW")
            Text("Good morning, operator.")
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .tracking(-1.2)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    TopBar { selectedTab = 2 }
                        .padding(.bottom, 34)
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .bottom, spacing: 12) {
                            overviewTitle
                            Spacer(minLength: 8)
                            ConnectionPill(syncTime: syncTime) { syncTime = "just now" }
                        }
                        VStack(alignment: .leading, spacing: 14) {
                            overviewTitle
                            ConnectionPill(syncTime: syncTime) { syncTime = "just now" }
                        }
                    }
                    .padding(.bottom, 20)
                    GlassCard(radius: 27) {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 7) {
                                    Eyebrow(text: "ACCOUNT FLEET")
                                    Text("128")
                                        .font(.system(size: 70, weight: .semibold, design: .rounded))
                                        .tracking(-4)
                                }
                                Spacer()
                                GlassCapsule(tint: GlassTheme.teal) {
                                    Text("DEMO MODE")
                                        .font(.system(size: 9, weight: .bold, design: .rounded))
                                        .tracking(1)
                                        .foregroundStyle(GlassTheme.teal)
                                }
                            }
                            HStack {
                                Text("Last sync \(syncTime)")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundStyle(GlassTheme.secondary)
                                Spacer()
                                Button("View accounts  ↗") { selectedTab = 1 }
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(GlassTheme.teal)
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    GlassEffectContainer(spacing: 10) {
                        HStack(spacing: 10) {
                            MetricCard(title: "Online", number: "112", detail: "87.5% of fleet", icon: "waveform.path.ecg", tint: GlassTheme.teal)
                            MetricCard(title: "Offline", number: "9", detail: "Needs attention", icon: "circle.dotted", tint: GlassTheme.amber)
                            MetricCard(title: "Issues", number: "7", detail: "Review required", icon: "exclamationmark", tint: GlassTheme.red)
                        }
                    }
                    .padding(.bottom, 34)
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 7) {
                            Eyebrow(text: "LIVE FEED")
                            Text("Recent activity").font(.system(size: 20, weight: .semibold, design: .rounded))
                        }
                        Spacer()
                        Label("Live", systemImage: "circle.fill")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(GlassTheme.teal)
                    }
                    .padding(.bottom, 10)
                    GlassCard(radius: 20) {
                        VStack(spacing: 0) {
                            ForEach(DemoData.activities) { item in
                                ActivityRow(item: item)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .background(Color.clear)
        }
    }
}

struct AccountsView: View {
    @State private var searchText = ""
    @State private var selectedAccount: Account?
    @State private var syncTime = "just now"

    private var filteredAccounts: [Account] {
        guard !searchText.isEmpty else { return DemoData.accounts }
        return DemoData.accounts.filter { account in
            account.phone.localizedCaseInsensitiveContains(searchText) || account.remark.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Eyebrow(text: "MANAGED ACCOUNTS")
                            Text("Accounts").font(.system(size: 34, weight: .semibold, design: .rounded))
                        }
                        Spacer()
                        Button { syncTime = "just now" } label: {
                            Image(systemName: "arrow.clockwise").frame(width: 42, height: 42)
                        }
                        .buttonStyle(LiquidGlassButtonStyle(tint: GlassTheme.groupedBackground, radius: 15))
                        .accessibilityLabel("Refresh accounts")
                    }
                    GlassSurface(radius: 15, tint: GlassTheme.groupedBackground, contentPadding: 14) {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass").foregroundStyle(GlassTheme.secondary)
                            TextField("Search accounts", text: $searchText)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                            if !searchText.isEmpty {
                                Button { searchText = "" } label: { Image(systemName: "xmark.circle.fill") }
                                    .foregroundStyle(GlassTheme.secondary)
                            }
                        }
                        .frame(minHeight: 48)
                    }
                    HStack {
                        Text("\(filteredAccounts.count) accounts")
                        Spacer()
                        Text("Sorted by activity")
                    }
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(GlassTheme.secondary)
                    LazyVStack(spacing: 8) {
                        ForEach(filteredAccounts) { account in
                            AccountRow(account: account) { selectedAccount = account }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .background(Color.clear)
            .sheet(item: $selectedAccount) { account in
                AccountDetailSheet(account: account, syncTime: syncTime)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

struct AccountDetailSheet: View {
    let account: Account
    let syncTime: String

    var body: some View {
        ZStack {
            Color.clear.background(.ultraThinMaterial).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 18) {
                AccountAvatar(initial: account.initial)
                Eyebrow(text: "ACCOUNT DETAIL")
                Text(account.phone).font(.system(size: 26, weight: .semibold, design: .rounded))
                StatusBadge(status: account.status)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    detailCell("Remark", account.remark)
                    detailCell("Last activity", account.lastActivity)
                    detailCell("Last sync", syncTime)
                    detailCell("Mode", "Demo")
                }
                Spacer()
            }
            .padding(24)
        }
    }

    private func detailCell(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(size: 9, design: .rounded)).foregroundStyle(GlassTheme.secondary)
            Text(value).font(.system(size: 11, weight: .semibold, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(GlassTheme.groupedBackground.opacity(0.16))
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 13))
            } else {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .strokeBorder(GlassTheme.glassEdge, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Eyebrow(text: "SYSTEM")
                    Text("Settings").font(.system(size: 34, weight: .semibold, design: .rounded))
                    GlassCard(radius: 20) {
                        VStack(spacing: 0) {
                            settingRow(icon: "network", title: "Connection", subtitle: "VPS endpoint", trailing: "Connected")
                            Divider().opacity(0.15)
                            settingRow(icon: "paintbrush", title: "Appearance", subtitle: "Liquid Glass · Dark", trailing: "chevron.right")
                            Divider().opacity(0.15)
                            settingRow(icon: "info.circle", title: "About TG Panel", subtitle: "Prototype build 0.1", trailing: "chevron.right")
                        }
                    }
                    GlassCard(radius: 19) {
                        Label {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Demo Mode").font(.system(size: 12, weight: .semibold, design: .rounded))
                                Text("This preview uses local sample data. No Telegram actions or network requests are made.")
                                    .font(.system(size: 10, design: .rounded))
                                    .foregroundStyle(GlassTheme.secondary)
                            }
                        } icon: {
                            Image(systemName: "sparkles").foregroundStyle(GlassTheme.teal)
                        }
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
            .background(Color.clear)
        }
    }

    private func settingRow(icon: String, title: String, subtitle: String, trailing: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(GlassTheme.teal)
                .frame(width: 30, height: 30)
                .background(GlassTheme.teal.opacity(0.12), in: .rect(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 13, weight: .semibold, design: .rounded))
                Text(subtitle).font(.system(size: 10, design: .rounded)).foregroundStyle(GlassTheme.secondary)
            }
            Spacer()
            if trailing == "Connected" {
                Text(trailing).font(.system(size: 10, design: .rounded)).foregroundStyle(GlassTheme.teal)
            } else {
                Image(systemName: trailing).foregroundStyle(GlassTheme.secondary)
            }
        }
        .padding(.vertical, 9)
    }
}

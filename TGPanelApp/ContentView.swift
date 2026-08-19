import SwiftUI

@main
struct TGPanelApp: App {
    @StateObject private var vm = PanelViewModel()
    @StateObject private var theme = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .environmentObject(theme)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Main ContentView with Dynamic Themed Liquid Glass
struct ContentView: View {
    @EnvironmentObject var vm: PanelViewModel
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedTab = 0
    @Namespace private var tabNamespace
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Dynamic Liquid Mesh Background (reacts to Theme)
            KanaDynamicLiquidMesh(theme: theme.currentTheme)
                .ignoresSafeArea()
            
            // 2. Tab Views
            Group {
                switch selectedTab {
                case 0:
                    AccountsView()
                case 1:
                    TasksView()
                case 2:
                    AutomationsView()
                case 3:
                    SettingsView()
                default:
                    AccountsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 78)
            
            // 3. Floating Liquid Glass TabBar (Matching Kana / 秋名山)
            KanaLiquidTabBar(selectedTab: $selectedTab, namespace: tabNamespace, theme: theme.currentTheme)
                .padding(.horizontal, 22)
                .padding(.bottom, 10)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $vm.showLogSheet) {
            LogSheetView()
        }
    }
}

// MARK: - Kana Dynamic Liquid Mesh Background
struct KanaDynamicLiquidMesh: View {
    let theme: AppTheme
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color(red: 3/255, green: 6/255, blue: 14/255)
            
            // Ambient Liquid Orb 1 (Primary Theme Color)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [theme.primaryColor.opacity(0.6), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 200
                    )
                )
                .frame(width: 380, height: 380)
                .offset(x: animate ? -70 : 80, y: animate ? -160 : -40)
                .blur(radius: 65)
            
            // Ambient Liquid Orb 2 (Secondary Theme Color)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [theme.secondaryColor.opacity(0.55), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 220
                    )
                )
                .frame(width: 420, height: 420)
                .offset(x: animate ? 100 : -80, y: animate ? 120 : 200)
                .blur(radius: 75)
            
            // Subtle White Core Specular Glow
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 260, height: 260)
                .offset(x: animate ? 40 : -40, y: animate ? 40 : -40)
                .blur(radius: 50)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6.5).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

// MARK: - Kana Floating Liquid TabBar
struct KanaLiquidTabBar: View {
    @Binding var selectedTab: Int
    var namespace: Namespace.ID
    let theme: AppTheme
    @EnvironmentObject var vm: PanelViewModel
    
    let tabs: [(index: Int, name: String, icon: String)] = [
        (0, "账号", "person.2.fill"),
        (1, "任务", "bolt.fill"),
        (2, "自动化", "wand.and.stars"),
        (3, "设置", "gearshape.fill")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.index) { tab in
                let isSelected = (selectedTab == tab.index)
                Button {
                    let gen = UIImpactFeedbackGenerator(style: .medium)
                    gen.impactOccurred()
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.72)) {
                        selectedTab = tab.index
                    }
                } label: {
                    VStack(spacing: 3) {
                        ZStack {
                            Image(systemName: tab.icon)
                                .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? .white : .white.opacity(0.45))
                                .shadow(color: isSelected ? theme.primaryColor : .clear, radius: 10)
                            
                            if tab.index == 1 && vm.runningTasksCount > 0 {
                                Text("\(vm.runningTasksCount)")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(theme.primaryColor)
                                    .clipShape(Capsule())
                                    .offset(x: 12, y: -8)
                            }
                        }
                        
                        Text(tab.name)
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? .white : .white.opacity(0.45))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .contentShape(Rectangle())
                    .background {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(theme.gradient.opacity(0.55))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.white.opacity(0.85), theme.primaryColor.opacity(0.6), .white.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(color: theme.primaryColor.opacity(0.45), radius: 12, y: 3)
                                .matchedGeometryEffect(id: "KANA_TAB_INDICATOR", in: namespace)
                        }
                    }
                }
            }
        }
        .padding(5)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .white.opacity(0.1), theme.primaryColor.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.7), radius: 24, y: 12)
        .shadow(color: theme.primaryColor.opacity(0.2), radius: 15)
    }
}

// MARK: - Floating Theme Selector (Matching Kana / 秋名山 Floating Palette)
struct FloatingThemeSelector: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var showSelector = false
    
    var body: some View {
        Menu {
            ForEach(AppTheme.allCases) { t in
                Button {
                    let gen = UIImpactFeedbackGenerator(style: .light)
                    gen.impactOccurred()
                    theme.currentTheme = t
                } label: {
                    HStack {
                        Text(t.rawValue)
                        if theme.currentTheme == t {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 5) {
                Circle()
                    .fill(theme.currentTheme.gradient)
                    .frame(width: 14, height: 14)
                    .shadow(color: theme.currentTheme.primaryColor, radius: 4)
                Text(theme.currentTheme.rawValue)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
        }
    }
}

// MARK: - 1. Accounts View (Kana Inset Grouped Style)
struct AccountsView: View {
    @EnvironmentObject var vm: PanelViewModel
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Filter Pills
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                FilterPill(title: "全量 (\(vm.accounts.count))", filterKey: "all", selected: vm.selectedFilter, theme: theme.currentTheme) {
                                    vm.selectedFilter = "all"
                                }
                                FilterPill(title: "在线 (\(vm.onlineCount))", filterKey: "online", selected: vm.selectedFilter, theme: theme.currentTheme) {
                                    vm.selectedFilter = "online"
                                }
                                FilterPill(title: "离线 (\(vm.offlineCount))", filterKey: "offline", selected: vm.selectedFilter, theme: theme.currentTheme) {
                                    vm.selectedFilter = "offline"
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                Task { await vm.triggerCheckOnline() }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.clockwise.circle.fill")
                                    Text("一键在线巡检")
                                }
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(theme.currentTheme.gradient)
                                .cornerRadius(18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
                                )
                                .shadow(color: theme.currentTheme.primaryColor.opacity(0.4), radius: 10, y: 4)
                            }
                            
                            if let exportUrl = URL(string: "\(vm.serverUrl)/api/sessions/export") {
                                Link(destination: exportUrl) {
                                    HStack {
                                        Image(systemName: "arrow.down.doc.fill")
                                        Text("导出 Session")
                                    }
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(18)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Accounts List (Kana Style Cards)
                        LazyVStack(spacing: 12) {
                            ForEach(vm.filteredAccounts) { acc in
                                KanaAccountCard(account: acc, theme: theme.currentTheme)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle("TG 账号列表")
            .searchable(text: $vm.searchText, prompt: "搜索手机号、ID、备注或名字...")
            .refreshable {
                await vm.fetchAccounts()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 8) {
                        FloatingThemeSelector()
                        
                        HStack(spacing: 5) {
                            Circle()
                                .fill(vm.isOnline ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                                .shadow(color: vm.isOnline ? .green : .red, radius: 4)
                            Text(vm.isOnline ? "在线" : "离线")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
                    }
                }
            }
        }
    }
}

// MARK: - Kana Style Account Card
struct KanaAccountCard: View {
    let account: AccountItem
    let theme: AppTheme
    @State private var copied = false
    
    var body: some View {
        HStack(spacing: 14) {
            // Left: Glowing Avatar Container
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(theme.gradient.opacity(0.35))
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .shadow(color: theme.primaryColor, radius: 6)
            }
            
            // Middle: Account Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(account.name ?? "未命名")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    if let remark = account.remark, !remark.isEmpty {
                        Text("(\(remark))")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                // Phone & Copy
                Button {
                    UIPasteboard.general.string = account.phone ?? ""
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
                } label: {
                    HStack(spacing: 4) {
                        Text(account.phone ?? "")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(theme.primaryColor)
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 10))
                            .foregroundColor(theme.primaryColor.opacity(0.8))
                    }
                }
                
                Text("TG ID: \(account.tg_user_id ?? "-")")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white.opacity(0.45))
            }
            
            Spacer()
            
            // Right: Online / Offline Liquid Capsule
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(account.isOnline ? Color.green : Color.red)
                        .frame(width: 7, height: 7)
                        .shadow(color: account.isOnline ? .green : .red, radius: 4)
                    Text(account.isOnline ? "在线" : "离线")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(account.isOnline ? .green : .red)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(account.isOnline ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(account.isOnline ? Color.green.opacity(0.4) : Color.red.opacity(0.4), lineWidth: 1)
                )
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .white.opacity(0.1), theme.primaryColor.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 12, y: 5)
    }
}

// MARK: - 2. Tasks View
struct TasksView: View {
    @EnvironmentObject var vm: PanelViewModel
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                
                ScrollView {
                    VStack(spacing: 16) {
                        if vm.tasks.isEmpty {
                            VStack(spacing: 14) {
                                Image(systemName: "bolt.slash.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(theme.primaryColor.opacity(0.5))
                                Text("暂无后台运行中的任务")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 80)
                        } else {
                            ForEach(Array(vm.tasks.values)) { task in
                                KanaTaskCard(task: task, theme: theme.currentTheme)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("任务调度队列")
            .refreshable {
                await vm.fetchTasks()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    FloatingThemeSelector()
                }
            }
        }
    }
}

struct KanaTaskCard: View {
    @EnvironmentObject var vm: PanelViewModel
    let task: TaskInfo
    let theme: AppTheme
    
    var progress: Double {
        guard let total = task.total, total > 0, let current = task.current else { return 0 }
        return Double(current) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(task.type ?? "任务 #\(task.id)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(task.status?.uppercased() ?? "RUNNING")
                    .font(.system(size: 11, weight: .heavy))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(theme.primaryColor.opacity(0.25))
                    .foregroundColor(theme.primaryColor)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(theme.primaryColor.opacity(0.5), lineWidth: 1)
                    )
            }
            
            ProgressView(value: progress)
                .tint(theme.primaryColor)
            
            HStack {
                Text("进度: \(task.current ?? 0) / \(task.total ?? 0) (\(Int(progress * 100))%)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text("延迟: \(task.delay_min ?? 1)-\(task.delay_max ?? 30)s")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            HStack(spacing: 10) {
                if task.status?.lowercased() == "running" {
                    Button {
                        Task { await vm.pauseTask(id: task.id) }
                    } label: {
                        Text("⏸ 暂停")
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.white.opacity(0.12))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else if task.status?.lowercased() == "paused" {
                    Button {
                        Task { await vm.resumeTask(id: task.id) }
                    } label: {
                        Text("▶️ 继续")
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.white.opacity(0.12))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                Button {
                    vm.viewLog(id: task.id)
                } label: {
                    Text("📜 实时日志")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.white.opacity(0.12))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Spacer()
                
                Button {
                    Task { await vm.cancelTask(id: task.id) }
                } label: {
                    Text("🛑 终止")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.red.opacity(0.3))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red.opacity(0.6), lineWidth: 1)
                        )
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 12, y: 5)
    }
}

// MARK: - 3. Automations View
struct AutomationsView: View {
    @EnvironmentObject var vm: PanelViewModel
    @EnvironmentObject var theme: ThemeManager
    @State private var showAutoVerifyAlert = false
    @State private var groupLink = ""
    @State private var showLuckyAlert = false
    @State private var luckyLink = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                
                ScrollView {
                    VStack(spacing: 16) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            
                            KanaActionCard(title: "自动进群验证", desc: "智能过人机验证", icon: "shield.righthalf.filled", color: theme.currentTheme.primaryColor) {
                                showAutoVerifyAlert = true
                            }
                            
                            KanaActionCard(title: "幸运星抽奖", desc: "批量全量账号福利", icon: "star.fill", color: .pink) {
                                showLuckyAlert = true
                            }
                            
                            KanaActionCard(title: "每日自动签到", desc: "多账号 Bot 自动化", icon: "checkmark.seal.fill", color: .green) {
                                Task { await vm.triggerCheckOnline() }
                            }
                            
                            if let exportUrl = URL(string: "\(vm.serverUrl)/api/sessions/export") {
                                Link(destination: exportUrl) {
                                    KanaActionCardContent(title: "导出全量会话", desc: "打包 .session 文件", icon: "archivebox.fill", color: .purple)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("自动化执行器")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    FloatingThemeSelector()
                }
            }
            .alert("自动进群验证", isPresented: $showAutoVerifyAlert) {
                TextField("目标群链接 (例如: @group)", text: $groupLink)
                Button("开始验证") {
                    Task { await vm.triggerAutoVerify(group: groupLink, minDelay: 1, maxDelay: 180) }
                }
                Button("取消", role: .cancel) {}
            }
            .alert("幸运星抽奖", isPresented: $showLuckyAlert) {
                TextField("抽奖链接", text: $luckyLink)
                Button("开始抽奖") {
                    Task { await vm.triggerLuckyStar(link: luckyLink) }
                }
                Button("取消", role: .cancel) {}
            }
        }
    }
}

struct KanaActionCard: View {
    let title: String
    let desc: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.impactOccurred()
            action()
        }) {
            KanaActionCardContent(title: title, desc: desc, icon: icon, color: color)
        }
    }
}

struct KanaActionCardContent: View {
    let title: String
    let desc: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.25))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.6), lineWidth: 1.5)
                )
                .shadow(color: color.opacity(0.4), radius: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.65))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 12, y: 5)
    }
}

// MARK: - 4. Settings View
struct SettingsView: View {
    @EnvironmentObject var vm: PanelViewModel
    @EnvironmentObject var theme: ThemeManager
    @State private var serverAddress: String = ""
    @State private var savedAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("VPS 服务器直连配置")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            
                            TextField("http://207.174.6.36:5000", text: $serverAddress)
                                .font(.system(size: 14, design: .monospaced))
                                .padding(14)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(theme.primaryColor.opacity(0.5), lineWidth: 1)
                                )
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                            
                            Button {
                                vm.serverUrl = serverAddress
                                vm.fetchData()
                                let gen = UINotificationFeedbackGenerator()
                                gen.notificationOccurred(.success)
                                savedAlert = true
                            } label: {
                                Text("💾 保存并连接 VPS")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(theme.currentTheme.gradient)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
                                    )
                                    .shadow(color: theme.primaryColor.opacity(0.4), radius: 10)
                            }
                        }
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
                        )
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("💎 TGPanel (秋名山同款主题引擎)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("v3.7.0")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(theme.primaryColor)
                            }
                            
                            Divider().background(Color.white.opacity(0.2))
                            
                            HStack {
                                Text("当前流体主题")
                                Spacer()
                                FloatingThemeSelector()
                            }
                            .font(.system(size: 13))
                            
                            HStack {
                                Text("渲染架构")
                                Spacer()
                                Text("Pure SwiftUI + UltraThinMaterial")
                                    .foregroundColor(.secondary)
                            }
                            .font(.system(size: 13))
                        }
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("系统设置")
            .onAppear {
                serverAddress = vm.serverUrl
            }
            .alert("配置已保存", isPresented: $savedAlert) {
                Button("确定", role: .cancel) {}
            }
        }
    }
}

// MARK: - Log Sheet View
struct LogSheetView: View {
    @EnvironmentObject var vm: PanelViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(vm.activeLogText)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color(red: 2/255, green: 4/255, blue: 8/255))
            .navigationTitle("任务实时日志")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Filter Pill View Helper
struct FilterPill: View {
    let title: String
    let filterKey: String
    let selected: String
    let theme: AppTheme
    let action: () -> Void
    
    var isSelected: Bool { selected == filterKey }
    
    var body: some View {
        Button(action: {
            let gen = UIImpactFeedbackGenerator(style: .light)
            gen.impactOccurred()
            action()
        }) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(
                    isSelected ?
                    theme.gradient.opacity(0.5) :
                    LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)], startPoint: .leading, endPoint: .trailing)
                )
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.white.opacity(0.85) : Color.white.opacity(0.2), lineWidth: 1.5)
                )
                .shadow(color: isSelected ? theme.primaryColor.opacity(0.35) : .clear, radius: 8)
        }
    }
}

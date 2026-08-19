import SwiftUI

@main
struct TGPanelApp: App {
    @StateObject private var vm = PanelViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Main ContentView with Custom Floating Liquid Glass TabBar
struct ContentView: View {
    @EnvironmentObject var vm: PanelViewModel
    @State private var selectedTab = 0
    @Namespace private var tabNamespace
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Live Ambient Dynamic Liquid Plasma Canvas
            LiquidPlasmaMeshBackground()
                .ignoresSafeArea()
            
            // 2. Active Screen Content
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
            // Extra bottom padding for floating liquid tabbar
            .padding(.bottom, 80)
            
            // 3. Floating VisionOS / iOS 27 Liquid Glass Capsule TabBar
            FloatingLiquidGlassTabBar(selectedTab: $selectedTab, namespace: tabNamespace)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $vm.showLogSheet) {
            LogSheetView()
        }
    }
}

// MARK: - Dynamic Organic Liquid Plasma Mesh Background
struct LiquidPlasmaMeshBackground: View {
    @State private var phase1: CGFloat = 0
    @State private var phase2: CGFloat = 0
    @State private var phase3: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Deep Obsidian Void Base
            Color(red: 2/255, green: 5/255, blue: 14/255)
            
            // Liquid Orb 1: Electric Cyan Plasma
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 0/255, green: 240/255, blue: 255/255).opacity(0.55), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(
                    x: cos(phase1) * 120 - 40,
                    y: sin(phase1) * 150 - 180
                )
                .blur(radius: 50)
            
            // Liquid Orb 2: Vivid Ultra-Violet Plasma
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 168/255, green: 40/255, blue: 255/255).opacity(0.6), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(
                    x: sin(phase2) * 130 + 60,
                    y: cos(phase2) * 160 + 100
                )
                .blur(radius: 60)
            
            // Liquid Orb 3: Laser Hot-Pink Plasma
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 255/255, green: 0/255, blue: 128/255).opacity(0.45), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .offset(
                    x: cos(phase3) * 100 - 80,
                    y: sin(phase3) * 120 + 220
                )
                .blur(radius: 50)
            
            // Liquid Orb 4: Emerald Aqua Glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 0/255, green: 255/255, blue: 160/255).opacity(0.4), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(
                    x: sin(phase1) * 90 + 90,
                    y: cos(phase3) * 110 - 50
                )
                .blur(radius: 45)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 7.0).repeatForever(autoreverses: true)) {
                phase1 = .pi * 2
            }
            withAnimation(.easeInOut(duration: 9.0).repeatForever(autoreverses: true)) {
                phase2 = .pi * 2
            }
            withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                phase3 = .pi * 2
            }
        }
    }
}

// MARK: - Floating Liquid Glass TabBar (The Ultimate Glass Experience)
struct FloatingLiquidGlassTabBar: View {
    @Binding var selectedTab: Int
    var namespace: Namespace.ID
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
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                        selectedTab = tab.index
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? .white : .white.opacity(0.45))
                                .shadow(color: isSelected ? .cyan : .clear, radius: 8)
                            
                            // Badge for running tasks
                            if tab.index == 1 && vm.runningTasksCount > 0 {
                                Text("\(vm.runningTasksCount)")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.cyan)
                                    .clipShape(Capsule())
                                    .offset(x: 12, y: -8)
                            }
                        }
                        
                        Text(tab.name)
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? .white : .white.opacity(0.45))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .contentShape(Rectangle())
                    .background {
                        if isSelected {
                            // Fluid Lava / Glass Bubble Indicator
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.cyan.opacity(0.45),
                                            Color.purple.opacity(0.55)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.white.opacity(0.9), .cyan.opacity(0.5), .white.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(color: Color.cyan.opacity(0.4), radius: 12, y: 4)
                                .matchedGeometryEffect(id: "LIQUID_TAB_BUBBLE", in: namespace)
                        }
                    }
                }
            }
        }
        .padding(6)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .white.opacity(0.15), .cyan.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.7), radius: 30, y: 15)
        .shadow(color: Color.cyan.opacity(0.15), radius: 20)
    }
}

// MARK: - View Modifier for True Liquid Glass Cards
struct LiquidGlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 24
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.75),
                                Color.cyan.opacity(0.4),
                                Color.purple.opacity(0.25),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.black.opacity(0.55), radius: 16, y: 8)
            .shadow(color: Color.cyan.opacity(0.12), radius: 15)
    }
}

extension View {
    func liquidGlassCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(LiquidGlassCardModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - 1. Accounts View (Pure Native Liquid Glass)
struct AccountsView: View {
    @EnvironmentObject var vm: PanelViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background transparent so mesh shines through
                Color.clear
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Filter Pills
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                FilterPill(title: "全量 (\(vm.accounts.count))", filterKey: "all", selected: vm.selectedFilter) {
                                    vm.selectedFilter = "all"
                                }
                                FilterPill(title: "在线 (\(vm.onlineCount))", filterKey: "online", selected: vm.selectedFilter) {
                                    vm.selectedFilter = "online"
                                }
                                FilterPill(title: "离线 (\(vm.offlineCount))", filterKey: "offline", selected: vm.selectedFilter) {
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
                                .background(
                                    LinearGradient(colors: [.cyan, .blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .cornerRadius(18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
                                )
                                .shadow(color: Color.cyan.opacity(0.4), radius: 10, y: 4)
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
                                    .liquidGlassCard(cornerRadius: 18)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Accounts List
                        LazyVStack(spacing: 12) {
                            ForEach(vm.filteredAccounts) { acc in
                                AccountRowCard(account: acc)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle("TG 账号管理")
            .searchable(text: $vm.searchText, prompt: "搜索手机号、ID、备注或名字...")
            .refreshable {
                await vm.fetchAccounts()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(vm.isOnline ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                            .shadow(color: vm.isOnline ? .green : .red, radius: 6)
                        Text(vm.isOnline ? "VPS 在线" : "离线")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .liquidGlassCard(cornerRadius: 20)
                }
            }
        }
    }
}

// MARK: - Account Row Glass Card
struct AccountRowCard: View {
    let account: AccountItem
    @State private var copied = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(account.isOnline ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                        .shadow(color: account.isOnline ? .green : .red, radius: 4)
                    
                    Text(account.name ?? "未命名")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    if let remark = account.remark, !remark.isEmpty {
                        Text("(\(remark))")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                Spacer()
                
                // Copy Phone Pill
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
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 11))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.cyan.opacity(0.25))
                    .foregroundColor(.cyan)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.cyan.opacity(0.6), lineWidth: 1)
                    )
                }
            }
            
            HStack(spacing: 12) {
                HStack {
                    Text("TG ID:")
                        .foregroundColor(.white.opacity(0.5))
                    Text(account.tg_user_id ?? "-")
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                }
                .font(.system(size: 12))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.06))
                .cornerRadius(8)
                
                HStack {
                    Text("状态:")
                        .foregroundColor(.white.opacity(0.5))
                    Text(account.isOnline ? "正常在线" : "异常离线")
                        .foregroundColor(account.isOnline ? .green : .red)
                        .font(.system(size: 12, weight: .bold))
                }
                .font(.system(size: 12))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.06))
                .cornerRadius(8)
            }
        }
        .padding(18)
        .liquidGlassCard(cornerRadius: 22)
    }
}

// MARK: - 2. Tasks Tab View
struct TasksView: View {
    @EnvironmentObject var vm: PanelViewModel
    
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
                                    .foregroundColor(.cyan.opacity(0.5))
                                Text("暂无后台运行中的任务")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 80)
                        } else {
                            ForEach(Array(vm.tasks.values)) { task in
                                TaskRowCard(task: task)
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
        }
    }
}

struct TaskRowCard: View {
    @EnvironmentObject var vm: PanelViewModel
    let task: TaskInfo
    
    var progress: Double {
        guard let total = task.total, total > 0, let current = task.current else { return 0 }
        return Double(current) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(task.type ?? "任务 #\(task.id)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(task.status?.uppercased() ?? "RUNNING")
                    .font(.system(size: 11, weight: .heavy))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.cyan.opacity(0.3))
                    .foregroundColor(.cyan)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.cyan.opacity(0.6), lineWidth: 1)
                    )
            }
            
            // Progress
            ProgressView(value: progress)
                .tint(.cyan)
            
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
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
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
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
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
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
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
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
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
        .padding(18)
        .liquidGlassCard(cornerRadius: 22)
    }
}

// MARK: - 3. Automations Tab View
struct AutomationsView: View {
    @EnvironmentObject var vm: PanelViewModel
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
                            
                            ActionCard(title: "自动进群验证", desc: "智能过人机验证", icon: "shield.righthalf.filled", color: .cyan) {
                                showAutoVerifyAlert = true
                            }
                            
                            ActionCard(title: "幸运星抽奖", desc: "批量全量账号福利", icon: "star.fill", color: .pink) {
                                showLuckyAlert = true
                            }
                            
                            ActionCard(title: "每日自动签到", desc: "多账号 Bot 自动化", icon: "checkmark.seal.fill", color: .green) {
                                Task { await vm.triggerCheckOnline() }
                            }
                            
                            if let exportUrl = URL(string: "\(vm.serverUrl)/api/sessions/export") {
                                Link(destination: exportUrl) {
                                    ActionCardContent(title: "导出全量会话", desc: "打包 .session 文件", icon: "archivebox.fill", color: .purple)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("自动化执行器")
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

struct ActionCard: View {
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
            ActionCardContent(title: title, desc: desc, icon: icon, color: color)
        }
    }
}

struct ActionCardContent: View {
    let title: String
    let desc: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(color)
                .frame(width: 52, height: 52)
                .background(color.opacity(0.25))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.6), lineWidth: 1.5)
                )
                .shadow(color: color.opacity(0.4), radius: 10)
            
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
        .padding(18)
        .liquidGlassCard(cornerRadius: 24)
    }
}

// MARK: - 4. Settings Tab View
struct SettingsView: View {
    @EnvironmentObject var vm: PanelViewModel
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
                                        .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
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
                                    .background(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
                                    )
                                    .shadow(color: Color.cyan.opacity(0.4), radius: 10)
                            }
                        }
                        .padding(20)
                        .liquidGlassCard(cornerRadius: 24)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("💎 TGPanel Vision Edition")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("v3.6.0")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.cyan)
                            }
                            
                            Divider().background(Color.white.opacity(0.2))
                            
                            HStack {
                                Text("渲染引擎")
                                Spacer()
                                Text("100% Pure SwiftUI Native")
                                    .foregroundColor(.secondary)
                            }
                            .font(.system(size: 13))
                            
                            HStack {
                                Text("视觉规范")
                                Spacer()
                                Text("iOS 27 Ultra Liquid Glass")
                                    .foregroundColor(.secondary)
                            }
                            .font(.system(size: 13))
                        }
                        .padding(20)
                        .liquidGlassCard(cornerRadius: 24)
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
                    LinearGradient(colors: [.cyan.opacity(0.4), .purple.opacity(0.5)], startPoint: .leading, endPoint: .trailing) :
                    LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)], startPoint: .leading, endPoint: .trailing)
                )
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.white.opacity(0.8) : Color.white.opacity(0.2), lineWidth: 1.5)
                )
                .shadow(color: isSelected ? Color.cyan.opacity(0.35) : .clear, radius: 8)
        }
    }
}

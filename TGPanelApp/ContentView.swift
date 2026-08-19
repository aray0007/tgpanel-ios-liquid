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

// MARK: - Main ContentView with Pure Transparent Liquid Glass
struct ContentView: View {
    @EnvironmentObject var vm: PanelViewModel
    @State private var selectedTab = 0
    @Namespace private var tabNamespace
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Organic Transparent Liquid Caustic Background
            TransparentLiquidCausticsBackground()
                .ignoresSafeArea()
            
            // 2. Tab Contents
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
            .padding(.bottom, 76)
            
            // 3. Ultra-Transparent Crystal Glass Floating TabBar
            TransparentCrystalTabBar(selectedTab: $selectedTab, namespace: tabNamespace)
                .padding(.horizontal, 22)
                .padding(.bottom, 12)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $vm.showLogSheet) {
            LogSheetView()
        }
    }
}

// MARK: - Pure Transparent Liquid Caustics Background (Soft Optical Wave Refraction)
struct TransparentLiquidCausticsBackground: View {
    @State private var waveOffset1: CGFloat = 0
    @State private var waveOffset2: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Deep Midnight Obsidian Base
            Color(red: 4/255, green: 7/255, blue: 15/255)
            
            // Liquid Water Light Wave 1 (Subtle Cyan Refraction)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 0/255, green: 220/255, blue: 255/255).opacity(0.32), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 220
                    )
                )
                .frame(width: 440, height: 440)
                .offset(x: sin(waveOffset1) * 90 - 40, y: cos(waveOffset1) * 120 - 150)
                .blur(radius: 60)
            
            // Liquid Water Light Wave 2 (Subtle Indigo Sheen)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 120/255, green: 80/255, blue: 255/255).opacity(0.3), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 240
                    )
                )
                .frame(width: 480, height: 480)
                .offset(x: cos(waveOffset2) * 110 + 60, y: sin(waveOffset2) * 140 + 120)
                .blur(radius: 70)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                waveOffset1 = .pi * 2
            }
            withAnimation(.easeInOut(duration: 10.0).repeatForever(autoreverses: true)) {
                waveOffset2 = .pi * 2
            }
        }
    }
}

// MARK: - Ultra-Transparent Floating Crystal TabBar
struct TransparentCrystalTabBar: View {
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
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = tab.index
                    }
                } label: {
                    VStack(spacing: 3) {
                        ZStack {
                            Image(systemName: tab.icon)
                                .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? .white : .white.opacity(0.45))
                                .shadow(color: isSelected ? Color.white.opacity(0.6) : .clear, radius: 8)
                            
                            if tab.index == 1 && vm.runningTasksCount > 0 {
                                Text("\(vm.runningTasksCount)")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                    .offset(x: 12, y: -8)
                            }
                        }
                        
                        Text(tab.name)
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? .white : .white.opacity(0.45))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .contentShape(Rectangle())
                    .background {
                        if isSelected {
                            // Transparent Crystal Droplet Lens
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.white.opacity(0.8), .white.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 8, y: 3)
                                .matchedGeometryEffect(id: "CRYSTAL_LENS", in: namespace)
                        }
                    }
                }
            }
        }
        .padding(5)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.55), .white.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.6), radius: 25, y: 12)
    }
}

// MARK: - ViewModifier for Pure Transparent Crystal Glass
struct TransparentGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 22
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.55),
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.25)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color.black.opacity(0.45), radius: 14, y: 6)
    }
}

extension View {
    func transparentGlass(cornerRadius: CGFloat = 22) -> some View {
        modifier(TransparentGlassModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - 1. Accounts View (Pure Transparent Glass)
struct AccountsView: View {
    @EnvironmentObject var vm: PanelViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Filter Pills
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                TransparentFilterPill(title: "全量 (\(vm.accounts.count))", filterKey: "all", selected: vm.selectedFilter) {
                                    vm.selectedFilter = "all"
                                }
                                TransparentFilterPill(title: "在线 (\(vm.onlineCount))", filterKey: "online", selected: vm.selectedFilter) {
                                    vm.selectedFilter = "online"
                                }
                                TransparentFilterPill(title: "离线 (\(vm.offlineCount))", filterKey: "offline", selected: vm.selectedFilter) {
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
                                .transparentGlass(cornerRadius: 18)
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
                                    .transparentGlass(cornerRadius: 18)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Accounts List
                        LazyVStack(spacing: 12) {
                            ForEach(vm.filteredAccounts) { acc in
                                TransparentAccountCard(account: acc)
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
                    HStack(spacing: 6) {
                        Circle()
                            .fill(vm.isOnline ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                            .shadow(color: vm.isOnline ? .green : .red, radius: 4)
                        Text(vm.isOnline ? "VPS 在线" : "离线")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .transparentGlass(cornerRadius: 20)
                }
            }
        }
    }
}

// MARK: - Transparent Account Card
struct TransparentAccountCard: View {
    let account: AccountItem
    @State private var copied = false
    
    var body: some View {
        HStack(spacing: 14) {
            // Left: Frosted Icon Container
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
                
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
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
                            .foregroundColor(.white.opacity(0.55))
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
                            .foregroundColor(.cyan)
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 10))
                            .foregroundColor(.cyan.opacity(0.8))
                    }
                }
                
                Text("TG ID: \(account.tg_user_id ?? "-")")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white.opacity(0.45))
            }
            
            Spacer()
            
            // Right: Online/Offline Pill
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
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(account.isOnline ? Color.green.opacity(0.4) : Color.red.opacity(0.4), lineWidth: 1)
                )
            }
        }
        .padding(14)
        .transparentGlass(cornerRadius: 22)
    }
}

// MARK: - 2. Tasks View
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
                                    .foregroundColor(.white.opacity(0.35))
                                Text("暂无后台运行中的任务")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 80)
                        } else {
                            ForEach(Array(vm.tasks.values)) { task in
                                TransparentTaskCard(task: task)
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

struct TransparentTaskCard: View {
    @EnvironmentObject var vm: PanelViewModel
    let task: TaskInfo
    
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
                    .background(.ultraThinMaterial)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
            
            ProgressView(value: progress)
                .tint(.cyan)
            
            HStack {
                Text("进度: \(task.current ?? 0) / \(task.total ?? 0) (\(Int(progress * 100))%)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.65))
                Spacer()
                Text("延迟: \(task.delay_min ?? 1)-\(task.delay_max ?? 30)s")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.65))
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
                            .background(Color.white.opacity(0.1))
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
                            .background(Color.white.opacity(0.1))
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
                        .background(Color.white.opacity(0.1))
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
                        .background(Color.red.opacity(0.25))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red.opacity(0.5), lineWidth: 1)
                        )
                }
            }
        }
        .padding(16)
        .transparentGlass(cornerRadius: 22)
    }
}

// MARK: - 3. Automations View
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
                            
                            TransparentActionCard(title: "自动进群验证", desc: "智能过人机验证", icon: "shield.righthalf.filled", color: .cyan) {
                                showAutoVerifyAlert = true
                            }
                            
                            TransparentActionCard(title: "幸运星抽奖", desc: "批量全量账号福利", icon: "star.fill", color: .pink) {
                                showLuckyAlert = true
                            }
                            
                            TransparentActionCard(title: "每日自动签到", desc: "多账号 Bot 自动化", icon: "checkmark.seal.fill", color: .green) {
                                Task { await vm.triggerCheckOnline() }
                            }
                            
                            if let exportUrl = URL(string: "\(vm.serverUrl)/api/sessions/export") {
                                Link(destination: exportUrl) {
                                    TransparentActionCardContent(title: "导出全量会话", desc: "打包 .session 文件", icon: "archivebox.fill", color: .purple)
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

struct TransparentActionCard: View {
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
            TransparentActionCardContent(title: title, desc: desc, icon: icon, color: color)
        }
    }
}

struct TransparentActionCardContent: View {
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
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .transparentGlass(cornerRadius: 22)
    }
}

// MARK: - 4. Settings View
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
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
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
                                    .transparentGlass(cornerRadius: 14)
                            }
                        }
                        .padding(20)
                        .transparentGlass(cornerRadius: 24)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("💎 TGPanel Vision Edition")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("v3.8.0")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Divider().background(Color.white.opacity(0.15))
                            
                            HStack {
                                Text("视觉风格")
                                Spacer()
                                Text("Pure Transparent Liquid Glass")
                                    .foregroundColor(.secondary)
                            }
                            .font(.system(size: 13))
                            
                            HStack {
                                Text("渲染架构")
                                Spacer()
                                Text("100% Pure SwiftUI UltraThinMaterial")
                                    .foregroundColor(.secondary)
                            }
                            .font(.system(size: 13))
                        }
                        .padding(20)
                        .transparentGlass(cornerRadius: 24)
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
struct TransparentFilterPill: View {
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
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .background(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.04))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.white.opacity(0.85) : Color.white.opacity(0.2), lineWidth: 1.2)
                )
                .shadow(color: isSelected ? Color.black.opacity(0.3) : .clear, radius: 6)
        }
    }
}

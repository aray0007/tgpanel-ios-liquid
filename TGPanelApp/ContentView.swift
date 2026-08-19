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

// MARK: - Main ContentView with Liquid Glass TabView
struct ContentView: View {
    @EnvironmentObject var vm: PanelViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Live Ambient Liquid Light Canvas
            LiquidBackgroundView()
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                AccountsView()
                    .tabItem {
                        Label("账号", systemImage: "person.2.fill")
                    }
                    .tag(0)
                
                TasksView()
                    .tabItem {
                        Label("任务", systemImage: "bolt.fill")
                    }
                    .badge(vm.runningTasksCount > 0 ? "\(vm.runningTasksCount)" : nil)
                    .tag(1)
                
                AutomationsView()
                    .tabItem {
                        Label("自动化", systemImage: "wand.and.stars")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Label("设置", systemImage: "gearshape.fill")
                    }
                    .tag(3)
            }
            .tint(.cyan)
        }
        .sheet(isPresented: $vm.showLogSheet) {
            LogSheetView()
        }
    }
}

// MARK: - Liquid Background View (Organic Floating Plasma Orbs)
struct LiquidBackgroundView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color(red: 4/255, green: 7/255, blue: 18/255)
            
            // Orb 1: Neon Cyan
            Circle()
                .fill(Color(red: 0/255, green: 240/255, blue: 255/255).opacity(0.35))
                .frame(width: 320, height: 320)
                .blur(radius: 70)
                .offset(x: animate ? -80 : 100, y: animate ? -120 : 80)
            
            // Orb 2: Ultra Purple
            Circle()
                .fill(Color(red: 157/255, green: 0/255, blue: 255/255).opacity(0.4))
                .frame(width: 340, height: 340)
                .blur(radius: 80)
                .offset(x: animate ? 120 : -90, y: animate ? 150 : -80)
            
            // Orb 3: Laser Pink
            Circle()
                .fill(Color(red: 255/255, green: 0/255, blue: 127/255).opacity(0.3))
                .frame(width: 300, height: 300)
                .blur(radius: 75)
                .offset(x: animate ? -50 : 80, y: animate ? 200 : 20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

// MARK: - Accounts Tab View (Pure Native SwiftUI Glass List)
struct AccountsView: View {
    @EnvironmentObject var vm: PanelViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Top Segmented Filter Pills
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
                    
                    // Quick Action Buttons
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
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
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
                                .padding(.vertical, 12)
                                .background(.ultraThinMaterial)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
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
                .padding(.vertical)
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
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
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
        VStack(alignment: .leading, spacing: 10) {
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
                    .padding(.vertical, 4)
                    .background(Color.cyan.opacity(0.2))
                    .foregroundColor(.cyan)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
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
                .background(Color.white.opacity(0.05))
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
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.45), Color.white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 10, y: 5)
    }
}

// MARK: - Tasks Tab View
struct TasksView: View {
    @EnvironmentObject var vm: PanelViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if vm.tasks.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "bolt.slash.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.4))
                            Text("暂无后台运行中的任务")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        ForEach(Array(vm.tasks.values)) { task in
                            TaskRowCard(task: task)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("任务调度队列")
            .refreshable {
                await vm.fetchTasks()
            }
        }
    }
}

// MARK: - Task Row Card
struct TaskRowCard: View {
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
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.cyan.opacity(0.2))
                    .foregroundColor(.cyan)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                    )
            }
            
            // Progress Bar
            ProgressView(value: progress)
                .tint(.cyan)
            
            HStack {
                Text("进度: \(task.current ?? 0) / \(task.total ?? 0) (\(Int(progress * 100))%)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                Text("延迟: \(task.delay_min ?? 1)-\(task.delay_max ?? 30)s")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            HStack(spacing: 8) {
                if task.status?.lowercased() == "running" {
                    Button {
                        Task { await vm.pauseTask(id: task.id) }
                    } label: {
                        Text("暂停")
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                } else if task.status?.lowercased() == "paused" {
                    Button {
                        Task { await vm.resumeTask(id: task.id) }
                    } label: {
                        Text("继续")
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                Button {
                    vm.viewLog(id: task.id)
                } label: {
                    Text("实时日志")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.1))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button {
                    Task { await vm.cancelTask(id: task.id) }
                } label: {
                    Text("终止")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red.opacity(0.4), lineWidth: 1)
                        )
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Automations Tab View
struct AutomationsView: View {
    @EnvironmentObject var vm: PanelViewModel
    @State private var showAutoVerifyAlert = false
    @State private var groupLink = ""
    @State private var showLuckyAlert = false
    @State private var luckyLink = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        
                        ActionCard(title: "自动进群验证", desc: "智能过人机验证码", icon: "shield.righthalf.filled", color: .cyan) {
                            showAutoVerifyAlert = true
                        }
                        
                        ActionCard(title: "幸运星抽奖", desc: "全量账号批量领福利", icon: "star.fill", color: .pink) {
                            showLuckyAlert = true
                        }
                        
                        ActionCard(title: "每日自动签到", desc: "多账号 Bot 签到打卡", icon: "checkmark.seal.fill", color: .green) {
                            Task { await vm.triggerCheckOnline() }
                        }
                        
                        if let exportUrl = URL(string: "\(vm.serverUrl)/api/sessions/export") {
                            Link(destination: exportUrl) {
                                ActionCardContent(title: "导出全量会话", desc: "打包 .session 会话文件", icon: "archivebox.fill", color: .purple)
                            }
                        }
                    }
                }
                .padding()
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
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.2))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.5), lineWidth: 1)
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
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Settings Tab View
struct SettingsView: View {
    @EnvironmentObject var vm: PanelViewModel
    @State private var serverAddress: String = ""
    @State private var savedAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("VPS 服务器连接配置") {
                    TextField("http://207.174.6.36:5000", text: $serverAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    Button("保存并测试连接") {
                        vm.serverUrl = serverAddress
                        vm.fetchData()
                        let gen = UINotificationFeedbackGenerator()
                        gen.notificationOccurred(.success)
                        savedAlert = true
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.cyan)
                }
                
                Section("关于 TGPanel iOS") {
                    HStack {
                        Text("设计规范")
                        Spacer()
                        Text("Pure SwiftUI Native Glass")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("核心内核")
                        Spacer()
                        Text("Apple UIKit + Async/Await")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("版本号")
                        Spacer()
                        Text("v3.5.0 Native")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
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
                .padding(.vertical, 8)
                .background(isSelected ? Color.cyan.opacity(0.3) : Color.white.opacity(0.07))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.cyan : Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

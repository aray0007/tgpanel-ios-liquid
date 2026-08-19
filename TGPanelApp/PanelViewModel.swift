import SwiftUI

// MARK: - Models
struct AccountItem: Identifiable, Codable {
    var id: String { String(db_id ?? (phone ?? UUID().uuidString)) }
    let db_id: Int?
    let phone: String?
    let name: String?
    let remark: String?
    let tg_user_id: String?
    let status: String?
    let last_check: String?
    
    var isOnline: Bool {
        return status?.lowercased() == "online"
    }
}

struct TaskInfo: Identifiable, Codable {
    var id: String
    let type: String?
    let status: String?
    let total: Int?
    let current: Int?
    let success: Int?
    let fail: Int?
    let delay_min: Int?
    let delay_max: Int?
}

// MARK: - View Model
@MainActor
class PanelViewModel: ObservableObject {
    @AppStorage("tg_server_url") var serverUrl: String = "http://207.174.6.36:5000"
    
    @Published var accounts: [AccountItem] = []
    @Published var tasks: [String: TaskInfo] = [:]
    @Published var isOnline: Bool = true
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    @Published var selectedFilter: String = "all"
    
    @Published var activeLogId: String? = nil
    @Published var activeLogText: String = ""
    @Published var showLogSheet: Bool = false
    
    private var timer: Timer?
    
    var runningTasksCount: Int {
        tasks.values.filter { $0.status?.lowercased() == "running" }.count
    }
    
    var onlineCount: Int {
        accounts.filter { $0.isOnline }.count
    }
    
    var offlineCount: Int {
        accounts.filter { !$0.isOnline }.count
    }
    
    var filteredAccounts: [AccountItem] {
        accounts.filter { acc in
            if selectedFilter == "online" && !acc.isOnline { return false }
            if selectedFilter == "offline" && acc.isOnline { return false }
            
            if !searchText.isEmpty {
                let q = searchText.lowercased()
                let phoneMatch = (acc.phone ?? "").lowercased().contains(q)
                let nameMatch = (acc.name ?? "").lowercased().contains(q)
                let remarkMatch = (acc.remark ?? "").lowercased().contains(q)
                let idMatch = (acc.tg_user_id ?? "").lowercased().contains(q)
                return phoneMatch || nameMatch || remarkMatch || idMatch
            }
            return true
        }
    }
    
    init() {
        startPolling()
    }
    
    func startPolling() {
        fetchData()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.fetchTasks()
            }
        }
    }
    
    func fetchData() {
        isLoading = true
        Task {
            await fetchAccounts()
            await fetchTasks()
            isLoading = false
        }
    }
    
    func fetchAccounts() async {
        guard let url = URL(string: "\(cleanUrl)/api/sessions") else { return }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200 {
                isOnline = true
                if let decoded = try? JSONDecoder().decode([AccountItem].self, from: data) {
                    self.accounts = decoded
                }
            } else {
                isOnline = false
            }
        } catch {
            isOnline = false
        }
    }
    
    func fetchTasks() async {
        guard let url = URL(string: "\(cleanUrl)/api/tasks") else { return }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200 {
                if let decoded = try? JSONDecoder().decode([String: TaskInfo].self, from: data) {
                    var mutable = decoded
                    for (k, v) in mutable {
                        var item = v
                        item.id = k
                        mutable[k] = item
                    }
                    self.tasks = mutable
                }
            }
        } catch {}
    }
    
    func triggerAutoVerify(group: String, minDelay: Int, maxDelay: Int) async {
        guard let url = URL(string: "\(cleanUrl)/api/auto_verify") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["group": group, "delay_min": minDelay, "delay_max": maxDelay]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        _ = try? await URLSession.shared.data(for: req)
        await fetchTasks()
    }
    
    func triggerLuckyStar(link: String) async {
        guard let url = URL(string: "\(cleanUrl)/api/luckystar") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["link": link]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        _ = try? await URLSession.shared.data(for: req)
        await fetchTasks()
    }
    
    func triggerCheckOnline() async {
        guard let url = URL(string: "\(cleanUrl)/api/check_accounts") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        _ = try? await URLSession.shared.data(for: req)
        await fetchTasks()
    }
    
    func pauseTask(id: String) async {
        guard let url = URL(string: "\(cleanUrl)/api/pause/\(id)") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        _ = try? await URLSession.shared.data(for: req)
        await fetchTasks()
    }
    
    func resumeTask(id: String) async {
        guard let url = URL(string: "\(cleanUrl)/api/resume/\(id)") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        _ = try? await URLSession.shared.data(for: req)
        await fetchTasks()
    }
    
    func cancelTask(id: String) async {
        guard let url = URL(string: "\(cleanUrl)/api/cancel/\(id)") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        _ = try? await URLSession.shared.data(for: req)
        await fetchTasks()
    }
    
    func viewLog(id: String) {
        activeLogId = id
        activeLogText = "正在拉取实时日志..."
        showLogSheet = true
        Task {
            await fetchLog(id: id)
        }
    }
    
    func fetchLog(id: String) async {
        guard let url = URL(string: "\(cleanUrl)/api/log/\(id)") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let str = String(data: data, encoding: .utf8) {
                self.activeLogText = str
            }
        } catch {
            self.activeLogText = "无法连接日志服务: \(error.localizedDescription)"
        }
    }
    
    private var cleanUrl: String {
        serverUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
}

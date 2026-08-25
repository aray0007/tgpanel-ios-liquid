import Foundation

enum AccountStatus: String, CaseIterable, Identifiable {
    case online
    case offline
    case warning
    case unauthorized

    var id: String { rawValue }

    var title: String {
        switch self {
        case .online: "Online"
        case .offline: "Offline"
        case .warning: "Review"
        case .unauthorized: "Unauthorized"
        }
    }
}

struct Account: Identifiable, Hashable {
    let id = UUID()
    let phone: String
    let remark: String
    let status: AccountStatus
    let lastActivity: String
    let initial: String
}

struct ActivityItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let time: String
    let symbol: String
    let tone: ActivityTone
}

enum ActivityTone {
    case success
    case neutral
    case warning
}

enum DemoData {
    static let accounts: [Account] = [
        Account(phone: "+1 929•••2608", remark: "小火箭", status: .online, lastActivity: "2 min ago", initial: "+1"),
        Account(phone: "+1 323•••5222", remark: "悲鸣屿行冥", status: .online, lastActivity: "6 min ago", initial: "+1"),
        Account(phone: "+1 786•••1921", remark: "Expo", status: .offline, lastActivity: "18 min ago", initial: "+1"),
        Account(phone: "+1 516•••9696", remark: "Mi", status: .online, lastActivity: "21 min ago", initial: "+1"),
        Account(phone: "+1 571•••2111", remark: "Siva", status: .warning, lastActivity: "32 min ago", initial: "+1"),
        Account(phone: "+234 802•••7628", remark: "Даша", status: .online, lastActivity: "41 min ago", initial: "+2"),
        Account(phone: "+880 197•••5906", remark: "Patricia", status: .unauthorized, lastActivity: "1 hr ago", initial: "+8"),
        Account(phone: "+91 858•••9469", remark: "Kenneth", status: .online, lastActivity: "2 hr ago", initial: "+9")
    ]

    static let activities: [ActivityItem] = [
        ActivityItem(title: "Session refreshed", detail: "+1 929•••2608 · 2 min ago", time: "09:42", symbol: "checkmark", tone: .success),
        ActivityItem(title: "Fleet sync completed", detail: "128 accounts checked · 8 min ago", time: "09:36", symbol: "arrow.clockwise", tone: .neutral),
        ActivityItem(title: "Account needs review", detail: "+234 802•••7521 · 14 min ago", time: "09:30", symbol: "exclamationmark", tone: .warning)
    ]
}

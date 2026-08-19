import SwiftUI

// MARK: - Liquid App Themes (Matching Kana / 秋名山 Design System)
enum AppTheme: String, CaseIterable, Identifiable {
    case cyan = "水蓝"
    case violet = "幻紫"
    case pink = "霓虹"
    case emerald = "翡翠"
    case amber = "日冕"
    
    var id: String { rawValue }
    
    var primaryColor: Color {
        switch self {
        case .cyan: return Color(red: 0/255, green: 240/255, blue: 255/255)
        case .violet: return Color(red: 168/255, green: 85/255, blue: 247/255)
        case .pink: return Color(red: 255/255, green: 0/255, blue: 127/255)
        case .emerald: return Color(red: 16/255, green: 185/255, blue: 129/255)
        case .amber: return Color(red: 245/255, green: 158/255, blue: 11/255)
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .cyan: return Color(red: 0/255, green: 112/255, blue: 243/255)
        case .violet: return Color(red: 236/255, green: 72/255, blue: 153/255)
        case .pink: return Color(red: 139/255, green: 92/255, blue: 246/255)
        case .emerald: return Color(red: 6/255, green: 182/255, blue: 212/255)
        case .amber: return Color(red: 239/255, green: 68/255, blue: 68/255)
        }
    }
    
    var gradient: LinearGradient {
        LinearGradient(colors: [primaryColor, secondaryColor], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

class ThemeManager: ObservableObject {
    @AppStorage("selected_app_theme") var currentThemeRaw: String = AppTheme.cyan.rawValue
    
    var currentTheme: AppTheme {
        get { AppTheme(rawValue: currentThemeRaw) ?? .cyan }
        set {
            currentThemeRaw = newValue.rawValue
            objectWillChange.send()
        }
    }
}

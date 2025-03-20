import SwiftUI

struct TabItem: Identifiable {
    let id = UUID()
    let key: String
    let title: String
    let icon: String
}

struct TabBarView: View {
    @State private var selectedTab: String = "training"
    
    let tabs: [TabItem] = [
        TabItem(key: "training", title: "训练", icon: "💪"),
        TabItem(key: "exercises", title: "动作", icon: "🎯"),
        TabItem(key: "start", title: "开始训练", icon: "▶️"),
        TabItem(key: "history", title: "历史", icon: "📅"),
        TabItem(key: "profile", title: "我的", icon: "👤")
    ]
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TrainingView()
                .tabItem {
                    Label("训练", systemImage: "figure.run")
                }
                .tag("training")
            
            ExercisesView()
                .tabItem {
                    Label("动作", systemImage: "dumbbell.fill")
                }
                .tag("exercises")
            
            StartWorkoutView()
                .tabItem {
                    Label("开始训练", systemImage: "play.circle.fill")
                }
                .tag("start")
            
            HistoryView()
                .tabItem {
                    Label("历史", systemImage: "clock.fill")
                }
                .tag("history")
            
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
                .tag("profile")
        }
        .tint(Color(hex: "7C3AED"))
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(hex: "FFFFFF")
            
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(hex: "7C3AED")]
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(hex: "6B7280")]
            
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(hex: "7C3AED")
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(hex: "6B7280")
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

#Preview {
    TabBarView()
} 
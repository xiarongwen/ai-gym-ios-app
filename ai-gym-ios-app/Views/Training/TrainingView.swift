import SwiftUI
import SceneKit

struct ExerciseItem: Identifiable {
    let id = UUID()
    let title: String
    let reps: String
    let sets: Int
}



struct TrainingView: View {
    @StateObject private var healthKitService = HealthKitService()
    @State private var exercises: [ExerciseItem] = [
        ExerciseItem(title: "引体向上", reps: "8次", sets: 4),
        ExerciseItem(title: "俯卧杠铃划船", reps: "30 下 × 8", sets: 4)
    ]
    @State private var showAuthSheet: Bool = false
    @State private var showProfileSheet: Bool = false
    
    @AppStorage("isAuthenticated") private var isAuthenticated: Bool = false
    
    var body: some View {
        FadeInView {
            ZStack {
                // 背景颜色
                Color(hex: "8B5CF6")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 顶部固定区域
                    VStack(alignment: .leading, spacing: 12) {
                        // 顶部标题栏
                        HStack {
                            Text("跟着感觉走")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: handleProfilePress) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                        // 副标题
                        Text("今天是否要锻炼还是休息？可以根据自己的健身目标和心情决定。")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        // 健康数据提示
                        Button(action: handleHealthKitPress) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 24, height: 24)
                                
                                Text(healthKitService.isAuthorized 
                                    ? "今日数据：步数 \(healthKitService.steps ?? 0)，心率 \(healthKitService.heartRate ?? 0)，消耗 \(Int(healthKitService.calories ?? 0)) 卡路里"
                                    : "请打开健康权限")
                                    .font(.footnote)
                                    .foregroundColor(.white)
                                    .lineLimit(3)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(16)
                    
                    // 可滚动的内容区域
                    ScrollView {
                        VStack(spacing: 16) {
                            // 训练计划区域
                            VStack(spacing: 12) {
                                HStack {
                                    Text("今日训练：")
                                        .foregroundColor(Color(hex: "1F2937"))
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        Text("背 + 二头")
                                            .foregroundColor(Color(hex: "1F2937"))
                                        
                                        Text("AI 推荐")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(hex: "7C3AED"))
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 1)
                                            .background(Color(hex: "E9D5FF"))
                                            .cornerRadius(4)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {}) {
                                        HStack(spacing: 4) {
                                            Text("下一个训练")
                                                .font(.footnote)
                                                .foregroundColor(Color(hex: "7C3AED"))
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(hex: "7C3AED"))
                                        }
                                    }
                                }
                                
                                HStack(spacing: 12) {
                                    TrainingInfoCard(title: "训练类型", content: "四分化训练")
                                    TrainingInfoCard(title: "目标肌群", content: "背、二头")
                                    TrainingInfoCard(title: "预估时长", content: "1小时")
                                }
                                
                                Button(action: {}) {
                                    Text("开始训练")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color(hex: "7C3AED"))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            
                            // 训练动作列表
                            VStack(spacing: 12) {
                                HStack {
                                    Text("6 个训练动作")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(hex: "1F2937"))
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 8) {
                                        Button(action: {}) {
                                            Text("添加动作")
                                                .font(.footnote)
                                                .foregroundColor(Color(hex: "7C3AED"))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 4)
                                                .background(Color(hex: "F3E8FF"))
                                                .cornerRadius(16)
                                        }
                                        
                                        Button(action: {}) {
                                            Text("指导")
                                                .font(.footnote)
                                                .foregroundColor(Color(hex: "7C3AED"))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 4)
                                                .background(Color(hex: "F3E8FF"))
                                                .cornerRadius(16)
                                        }
                                    }
                                }
                                
                                VStack(spacing: 8) {
                                    ForEach(exercises) { exercise in
                                        ExerciseItemView(exercise: exercise)
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .padding(16)
                        .padding(.bottom, 80) // 底部额外间距，防止被底部标签栏遮挡
                    }
                    .background(Color(hex: "F3F4F6"))
                    .cornerRadius(24, corners: [.topLeft, .topRight]) // 顶部圆角
                }
            }
            .sheet(isPresented: $showAuthSheet) {
                AuthView()
            }
            .sheet(isPresented: $showProfileSheet) {
                ProfileView()
            }
        }
    }
    
    private func handleHealthKitPress() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func handleProfilePress() {
        if isAuthenticated {
            showProfileSheet = true
        } else {
            showAuthSheet = true
        }
    }
}

// 训练信息卡片
struct TrainingInfoCard: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.footnote)
                .foregroundColor(Color(hex: "581C87"))
            
            Text(content)
                .font(.footnote)
                .foregroundColor(Color(hex: "7E22CE"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color(hex: "F3E8FF"))
        .cornerRadius(8)
    }
}

// 训练动作项
struct ExerciseItemView: View {
    let exercise: ExerciseItem
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color(hex: "E5E7EB"))
                    .frame(width: 40, height: 40)
                    .cornerRadius(8)
                
                VStack(alignment: .leading) {
                    Text(exercise.title)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "1F2937"))
                    
                    Text("\(exercise.reps) × \(exercise.sets)组")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "6B7280"))
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "9CA3AF"))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// 扩展 View 以支持特定角落的圆角
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// 扩展 Color 以支持十六进制颜色代码
extension Color {
    init(hex: String) {
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
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    TrainingView()
} 

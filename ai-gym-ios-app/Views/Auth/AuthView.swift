import SwiftUI
import AuthenticationServices

// MARK: - Models
struct UserProfile {
    var height: Double = 170
    var weight: Double = 65
    var bodyFat: Double = 20
    var goal: TrainingGoal = .increase
}

enum TrainingGoal: String, CaseIterable {
    case increase = "increase"
    case decrease = "decrease"
    case shape = "shape"
    case specific = "specific"
    
    var label: String {
        switch self {
        case .increase: return "增肌"
        case .decrease: return "减脂"
        case .shape: return "塑形"
        case .specific: return "专项"
        }
    }
    
    var icon: String {
        switch self {
        case .increase: return "figure.strengthtraining.traditional"
        case .decrease: return "flame.fill"
        case .shape: return "figure.walk"
        case .specific: return "target"
        }
    }
}

// MARK: - Views
struct AuthView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(StorageKeys.isAuthenticated) private var isAuthenticated = false
    @AppStorage(StorageKeys.accessToken) private var accessToken = ""
    
    @State private var currentStep = 0
    @State private var phone = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var userProfile = UserProfile()
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // 进度条
                    ProgressView(value: Double(currentStep + 1), total: 3)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    VStack(spacing: 24) {
                        // 标题区域
                        VStack(alignment: .leading, spacing: 8) {
                            Text(stepTitle)
                                .font(.system(size: 32, weight: .bold))
                            
                            Text(stepSubtitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 32)
                        
                        // 主要内容区域
                        stepContent
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: handleBack) {
                        Image(systemName: currentStep == 0 ? "xmark" : "chevron.left")
                    }
                }
            }
        }
    }
    
    private var stepTitle: String {
        switch currentStep {
        case 0: return "登录"
        case 1: return "基本信息"
        case 2: return "训练目标"
        default: return ""
        }
    }
    
    private var stepSubtitle: String {
        switch currentStep {
        case 0: return "请登录后继续"
        case 1: return "请填写您的身体数据"
        case 2: return "选择您的训练目标"
        default: return ""
        }
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0:
            loginStep
        case 1:
            profileStep
        case 2:
            goalStep
        default:
            EmptyView()
        }
    }
    
    // MARK: - Step Views
    private var loginStep: some View {
        VStack(spacing: 16) {
            // 手机号输入框
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(.gray)
                    .padding(.leading)
                
                TextField("请输入手机号", text: $phone)
                    .keyboardType(.numberPad)
                    .textContentType(.telephoneNumber)
                    .padding()
            }
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(showError ? Color.red : Color.clear, lineWidth: 1)
            )
            
            // 添加密码输入框
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .padding(.leading)
                
                SecureField("请输入密码", text: $password)
                    .textContentType(.password)
                    .padding()
            }
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // 下一步按钮
            Button(action: handlePhoneLogin) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("下一步")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isLoading ? Color.accentColor.opacity(0.8) : Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(isLoading)
            
            // Apple登录按钮
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    handleAppleLogin(result)
                }
            )
            .frame(height: 50)
            .cornerRadius(10)
        }
    }
    
    private var profileStep: some View {
        VStack(spacing: 24) {
            NumberInputField(
                title: "身高 (cm)",
                value: Binding(
                    get: { userProfile.height },
                    set: { userProfile.height = $0 }
                ),
                range: 140...220,
                step: 1
            )
            
            NumberInputField(
                title: "体重 (kg)",
                value: Binding(
                    get: { userProfile.weight },
                    set: { userProfile.weight = $0 }
                ),
                range: 30...200,
                step: 0.5
            )
            
            NumberInputField(
                title: "体脂率 (%)",
                value: Binding(
                    get: { userProfile.bodyFat },
                    set: { userProfile.bodyFat = $0 }
                ),
                range: 5...50,
                step: 0.1
            )
            
            Button(action: handleNext) {
                Text("下一步")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    private var goalStep: some View {
        VStack(spacing: 24) {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(TrainingGoal.allCases, id: \.self) { goal in
                    Button(action: { userProfile.goal = goal }) {
                        VStack(spacing: 12) {
                            Image(systemName: goal.icon)
                                .font(.system(size: 32))
                            Text(goal.label)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(userProfile.goal == goal ? Color.accentColor : Color(.systemGray6))
                        .foregroundColor(userProfile.goal == goal ? .white : .primary)
                        .cornerRadius(12)
                    }
                }
            }
            
            Button(action: handleComplete) {
                Text("完成")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isLoading)
        }
    }
    
    // MARK: - Actions
    private func handleBack() {
        if currentStep == 0 {
            dismiss()
        } else {
            currentStep -= 1
        }
    }
    
    private func handleNext() {
        currentStep += 1
    }
    
    private func handlePhoneLogin() {
        // 重置错误状态
        showError = false
        errorMessage = ""
        
        // 验证手机号格式
        let phoneRegex = "^1[3-9]\\d{9}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        
        guard phonePredicate.evaluate(with: phone) else {
            showError = true
            errorMessage = "请输入正确的手机号码"
            return
        }
        
        guard !password.isEmpty else {
            showError = true
            errorMessage = "请输入密码"
            return
        }
        
        isLoading = true
        
        // 使用 async/await 进行网络请求
        Task {
            do {
                let loginRequest = LoginRequest(phone: phone, password: password)
                let response: LoginResponse = try await NetworkService.shared.request(
                    endpoint: "/auth/login",
                    method: .post,
                    body: loginRequest,
                    requiresAuth: false
                )
                
                await MainActor.run {
                    // 使用相同的键名保存 token
                    UserDefaults.standard.set(response.access_token, forKey: StorageKeys.accessToken)
                    accessToken = response.access_token
                    isLoading = false
                    handleNext()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    showError = true
                    errorMessage = handleError(error)
                }
            }
        }
    }
    
    private func handleAppleLogin(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let _ = authorization.credential as? ASAuthorizationAppleIDCredential {
                handleNext()
            }
        case .failure(let error):
            print("Apple Sign In failed:", error)
        }
    }
    
    private func handleComplete() {
        isLoading = true
        
        // TODO: Implement API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
            isAuthenticated = true
            dismiss()
        }
    }
    
    private func handleError(_ error: Error) -> String {
        switch error {
        case NetworkError.unauthorized:
            return "用户名或密码错误"
        case NetworkError.networkError:
            return "网络连接错误"
        case NetworkError.serverError(let message):
            return "服务器错误: \(message)"
        case NetworkError.decodingError:
            return "数据解析错误"
        default:
            return "未知错误"
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: StorageKeys.accessToken)
        UserDefaults.standard.removeObject(forKey: StorageKeys.isAuthenticated)
        isAuthenticated = false
        accessToken = ""
    }
}

// MARK: - Supporting Views
struct NumberInputField: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    
    private var values: [Double] {
        Array(stride(from: range.lowerBound, through: range.upperBound, by: step))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Picker("", selection: $value) {
                ForEach(values, id: \.self) { number in
                    Text(String(format: "%.1f", number))
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

// 添加响应模型
private struct LoginResponse: Codable {
    let access_token: String
    let user: User
    
    struct User: Codable {
        let id: String
        let phone: String
        let nickname: String
    }
}

// 在 LoginResponse 之前添加以下代码
private struct LoginRequest: Codable {
    let phone: String
    let password: String
}

#Preview {
    AuthView()
}

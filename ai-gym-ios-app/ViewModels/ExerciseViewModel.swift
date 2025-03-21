import Foundation
import Network

enum ExerciseError: LocalizedError {
    case networkNotConnected
    case invalidURL
    case serverError(Int)
    case decodingError
    case unknownError(Error)
    case connectionError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkNotConnected:
            return "网络连接失败，请检查网络设置"
        case .invalidURL:
            return "无效的URL"
        case .serverError(let code):
            return "服务器错误（\(code)），请稍后重试"
        case .decodingError:
            return "数据解析错误"
        case .connectionError(let details):
            return "连接服务器失败：\(details)"
        case .unknownError(let error):
            return "未知错误：\(error.localizedDescription)"
        }
    }
}

@MainActor
class ExerciseViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var currentPage = 1
    private var hasMorePages = true
    private let pageSize = 20
    
    private let networkMonitor = NWPathMonitor()
    private var isNetworkConnected = false
    
    // 在开发环境中使用本机IP地址，确保iOS模拟器/设备可以访问
    #if DEBUG
    // 使用本机的实际IP地址，可以通过终端运行 `ipconfig getifaddr en0` 获取
    private let baseURL = "http://10.10.10.117:3001"
    #else
    private let baseURL = "https://your-production-server.com"
    #endif
    
    init() {
        setupNetworkMonitoring()
        #if DEBUG
        // 打印当前网络接口信息，帮助调试
        printNetworkInterfaces()
        #endif
    }
    
    private func printNetworkInterfaces() {
        let host = ProcessInfo.processInfo.hostName
        print("主机名：\(host)")
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else {
            print("无法获取网络接口信息")
            return
        }
        defer { freeifaddrs(ifaddr) }
        
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            
            let interface = ptr?.pointee
            let addrFamily = interface?.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET) {
                let name = String(cString: (interface?.ifa_name)!)
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface?.ifa_addr,
                           socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                           &hostname,
                           socklen_t(hostname.count),
                           nil,
                           0,
                           NI_NUMERICHOST)
                let address = String(cString: hostname)
                print("接口: \(name), IP地址: \(address)")
            }
        }
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.isNetworkConnected = path.status == .satisfied
                print("网络状态：\(path.status == .satisfied ? "已连接" : "未连接")")
                
                let interfaces = path.availableInterfaces
                if !interfaces.isEmpty {
                    print("可用网络接口：\(interfaces.map { $0.name })")
                }
                
                if self.isNetworkConnected && self.exercises.isEmpty {
                    await self.fetchExercises()
                }
            }
        }
        networkMonitor.start(queue: DispatchQueue.global())
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    func fetchExercises() async {
        guard hasMorePages && !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let response: ExerciseResponse = try await NetworkService.shared.request(
                endpoint: "/exercises?page=\(currentPage)&pageSize=\(pageSize)",
                method: .get
            )
            
            if response.code == 200 {
                exercises.append(contentsOf: response.data)
                // 更新分页信息
                if let currentPageInt = Int(response.pagination.page) {
                    currentPage = currentPageInt + 1
                }
                hasMorePages = currentPage <= response.pagination.totalPages
            } else {
                throw NetworkError.serverError("错误代码：\(response.code)")
            }
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    func refresh() async {
        exercises = []
        currentPage = 1
        hasMorePages = true
        await fetchExercises()
    }
} 
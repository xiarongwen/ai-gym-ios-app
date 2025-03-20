import HealthKit
import Foundation

class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    @Published var steps: Int?
    @Published var heartRate: Int?
    @Published var calories: Double?
    
    init() {
        checkAuthorization()
    }
    
    func checkAuthorization() {
        // 检查 HealthKit 是否可用
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit 不可用")
            return
        }
        
        // 定义需要读取的数据类型
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        // 请求权限
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if success {
                    self?.fetchTodayData()
                }
            }
        }
    }
    
    func fetchTodayData() {
        fetchSteps()
        fetchHeartRate()
        fetchCalories()
    }
    
    private func fetchSteps() {
        let stepsType = HKQuantityType(.stepCount)
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepsType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, statistics, error in
            DispatchQueue.main.async {
                if let sum = statistics?.sumQuantity() {
                    self?.steps = Int(sum.doubleValue(for: .count()))
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchHeartRate() {
        let heartRateType = HKQuantityType(.heartRate)
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: heartRateType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { [weak self] _, statistics, error in
            DispatchQueue.main.async {
                if let average = statistics?.averageQuantity() {
                    self?.heartRate = Int(average.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchCalories() {
        let caloriesType = HKQuantityType(.activeEnergyBurned)
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: caloriesType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, statistics, error in
            DispatchQueue.main.async {
                if let sum = statistics?.sumQuantity() {
                    self?.calories = sum.doubleValue(for: .kilocalorie())
                }
            }
        }
        
        healthStore.execute(query)
    }
} 
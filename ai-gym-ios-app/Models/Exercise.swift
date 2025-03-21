import Foundation

struct ExerciseResponse: Codable {
    let code: Int
    let message: String
    let data: [Exercise]
    let pagination: Pagination
}

struct Pagination: Codable {
    let total: Int
    let page: String
    let limit: Int
    let totalPages: Int
}

struct Exercise: Codable, Identifiable {
    let id: Int
    let _id: String
    let name: String
    let bodyPart: String
    let equipment: String
    let gifUrl: String
    let target: String
    var secondaryMuscles: [String]
    var instructions: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, _id, name, bodyPart, equipment, gifUrl, target
        case secondaryMuscles, instructions
    }
}

// 用于UI展示的扩展
extension Exercise {
    var formattedBodyPart: String {
        switch bodyPart {
        case "waist": return "腰部"
        case "upper legs": return "大腿"
        case "back": return "背部"
        case "lower legs": return "小腿"
        case "chest": return "胸部"
        default: return bodyPart
        }
    }
    
    var formattedTarget: String {
        switch target {
        case "abs": return "腹肌"
        case "quads": return "股四头肌"
        case "lats": return "背阔肌"
        case "calves": return "小腿肌"
        case "pectorals": return "胸大肌"
        default: return target
        }
    }
    
    var formattedEquipment: String {
        switch equipment {
        case "body weight": return "徒手"
        case "cable": return "缆绳"
        case "leverage machine": return "器械"
        case "assisted": return "辅助"
        default: return equipment
        }
    }
} 
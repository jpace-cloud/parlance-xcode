import Foundation

struct Contract: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let category: String?
    let status: String?
}

import Foundation

struct GlossaryTerm: Codable, Identifiable {
    let id: String
    let name: String
    let rawValue: String?
    let category: String?
    let translations: [String: String]?
}

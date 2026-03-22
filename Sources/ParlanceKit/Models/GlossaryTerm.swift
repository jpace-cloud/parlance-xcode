import Foundation

public struct GlossaryTerm: Codable, Identifiable {
    public let id: String
    public let name: String
    public let rawValue: String?
    public let category: String?
    public let translations: [String: String]?

    public init(id: String, name: String, rawValue: String? = nil, category: String? = nil, translations: [String: String]? = nil) {
        self.id = id
        self.name = name
        self.rawValue = rawValue
        self.category = category
        self.translations = translations
    }
}

import Foundation

public struct Project: Codable, Identifiable {
    public let id: String
    public let name: String
    public let description: String?
    public let platforms: [String]?

    public init(id: String, name: String, description: String? = nil, platforms: [String]? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.platforms = platforms
    }
}

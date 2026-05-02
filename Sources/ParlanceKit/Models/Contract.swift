import Foundation

// shape unification deferred — see Tier 1.1 audit

public struct Contract: Codable, Identifiable {
    public let id: String
    public let name: String
    public let description: String?
    public let category: String?
    public let status: String?
    public let origin: Origin?

    public init(
        id: String,
        name: String,
        description: String? = nil,
        category: String? = nil,
        status: String? = nil,
        origin: Origin? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.status = status
        self.origin = origin
    }
}

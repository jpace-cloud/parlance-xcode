import Foundation

// keep in sync with parlance-types/src/origin.ts
// TypeScript port: jpace-cloud/parlance-types

public struct SnapshotRef: Codable, Sendable, Equatable {
    public let url: String
    public let capturedAt: String
    public let sha256: String?

    public init(url: String, capturedAt: String, sha256: String? = nil) {
        self.url = url
        self.capturedAt = capturedAt
        self.sha256 = sha256
    }
}

public struct TokenRef: Codable, Sendable, Equatable {
    public let name: String
    public let value: String?

    public init(name: String, value: String? = nil) {
        self.name = name
        self.value = value
    }
}

public struct ComponentRef: Codable, Sendable, Equatable {
    public let key: String
    public let name: String

    public init(key: String, name: String) {
        self.key = key
        self.name = name
    }
}

public enum Origin: Codable, Sendable, Equatable {
    case figmaFrame(FigmaFrame)
    case liveURL(LiveURL)
    case imageUpload(ImageUpload)
    case codeComponent(CodeComponent)
    case generated(Generated)
    case legacy(Legacy)
    case unspecified(Unspecified)

    public struct FigmaFrame: Codable, Sendable, Equatable {
        public let fileKey: String
        public let nodeId: String
        public let version: String?
        public let snapshot: SnapshotRef
        public let resolvedTokens: [TokenRef]?
        public let resolvedComponents: [ComponentRef]?
    }

    public struct LiveURL: Codable, Sendable, Equatable {
        public struct Viewport: Codable, Sendable, Equatable {
            public let w: Int
            public let h: Int
        }
        public let url: String
        public let viewport: Viewport
        public let capturedAt: String
        public let snapshot: SnapshotRef
        public let domDump: String?
    }

    public struct ImageUpload: Codable, Sendable, Equatable {
        public let snapshot: SnapshotRef
        public let originalFilename: String
        public let uploadedBy: String
    }

    public struct CodeComponent: Codable, Sendable, Equatable {
        public let repoUrl: String
        public let path: String
        public let ref: String
        public let storyName: String?
        public let snapshot: SnapshotRef
    }

    public struct Generated: Codable, Sendable, Equatable {
        public let prompt: String
        public let model: String
        public let snapshot: SnapshotRef
    }

    public struct Legacy: Codable, Sendable, Equatable {
        public let migratedAt: String
    }

    public struct Unspecified: Codable, Sendable, Equatable {
        public let stampedAt: String
    }

    private enum DiscriminatorKey: String, CodingKey { case type }

    private enum DiscriminatorValue: String {
        case figmaFrame = "figma_frame"
        case liveURL = "live_url"
        case imageUpload = "image_upload"
        case codeComponent = "code_component"
        case generated
        case legacy
        case unspecified
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DiscriminatorKey.self)
        let raw = try container.decode(String.self, forKey: .type)
        guard let kind = DiscriminatorValue(rawValue: raw) else {
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown origin type '\(raw)'"
            )
        }
        switch kind {
        case .figmaFrame:    self = .figmaFrame(try FigmaFrame(from: decoder))
        case .liveURL:       self = .liveURL(try LiveURL(from: decoder))
        case .imageUpload:   self = .imageUpload(try ImageUpload(from: decoder))
        case .codeComponent: self = .codeComponent(try CodeComponent(from: decoder))
        case .generated:     self = .generated(try Generated(from: decoder))
        case .legacy:        self = .legacy(try Legacy(from: decoder))
        case .unspecified:   self = .unspecified(try Unspecified(from: decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .figmaFrame(let v):    try v.encode(to: encoder); try writeType(.figmaFrame,    encoder: encoder)
        case .liveURL(let v):       try v.encode(to: encoder); try writeType(.liveURL,       encoder: encoder)
        case .imageUpload(let v):   try v.encode(to: encoder); try writeType(.imageUpload,   encoder: encoder)
        case .codeComponent(let v): try v.encode(to: encoder); try writeType(.codeComponent, encoder: encoder)
        case .generated(let v):     try v.encode(to: encoder); try writeType(.generated,     encoder: encoder)
        case .legacy(let v):        try v.encode(to: encoder); try writeType(.legacy,        encoder: encoder)
        case .unspecified(let v):   try v.encode(to: encoder); try writeType(.unspecified,   encoder: encoder)
        }
    }

    private func writeType(_ value: DiscriminatorValue, encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DiscriminatorKey.self)
        try container.encode(value.rawValue, forKey: .type)
    }
}

import Foundation

enum ParlanceAPIError: Error, LocalizedError {
    case networkError(Error)
    case unauthorized
    case notFound
    case serverError(Int)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .networkError(let e): return "Network error: \(e.localizedDescription)"
        case .unauthorized: return "Invalid or missing API key"
        case .notFound: return "Resource not found"
        case .serverError(let code): return "Server error (\(code))"
        case .decodingError(let e): return "Failed to decode response: \(e.localizedDescription)"
        }
    }
}

private struct APIResponse<T: Decodable>: Decodable {
    let data: T?
    let error: String?
}

private struct PushPayload: Encodable {
    let filePath: String
    let results: [AuditResult]
    let timestamp: String
}

private struct PushResponse: Decodable {
    let inserted: Int
}

class ParlanceAPIClient {
    private let baseURL: String
    private let apiKey: String
    private let session: URLSession

    private var clientVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    init(apiKey: String, baseURL: String = "https://api.parlance.business") {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.session = URLSession(configuration: .default)
    }

    private func makeRequest(path: String, method: String = "GET", body: Data? = nil) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw ParlanceAPIError.networkError(URLError(.badURL))
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("xcode-extension/\(clientVersion)", forHTTPHeaderField: "X-Parlance-Client")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body {
            request.httpBody = body
        }
        return request
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw ParlanceAPIError.networkError(error)
        }

        if let http = response as? HTTPURLResponse {
            switch http.statusCode {
            case 200...299: break
            case 401: throw ParlanceAPIError.unauthorized
            case 404: throw ParlanceAPIError.notFound
            default: throw ParlanceAPIError.serverError(http.statusCode)
            }
        }

        do {
            let decoded = try JSONDecoder().decode(APIResponse<T>.self, from: data)
            if let value = decoded.data {
                return value
            }
            throw ParlanceAPIError.decodingError(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: decoded.error ?? "No data in response")))
        } catch let error as ParlanceAPIError {
            throw error
        } catch {
            throw ParlanceAPIError.decodingError(error)
        }
    }

    func testConnection() async throws -> Bool {
        let request = try makeRequest(path: "/v1/projects")
        let _: [Project] = try await perform(request)
        return true
    }

    func fetchProjects() async throws -> [Project] {
        let request = try makeRequest(path: "/v1/projects")
        return try await perform(request)
    }

    func fetchContracts(projectId: String) async throws -> [Contract] {
        let request = try makeRequest(path: "/v1/projects/\(projectId)/contracts")
        return try await perform(request)
    }

    func fetchGlossary(projectId: String) async throws -> [GlossaryTerm] {
        let request = try makeRequest(path: "/v1/projects/\(projectId)/glossary")
        return try await perform(request)
    }

    func pushAuditResults(projectId: String, results: [AuditResult], filePath: String) async throws -> Int {
        let formatter = ISO8601DateFormatter()
        let payload = PushPayload(
            filePath: filePath,
            results: results,
            timestamp: formatter.string(from: Date())
        )
        let body = try JSONEncoder().encode(payload)
        let request = try makeRequest(path: "/v1/projects/\(projectId)/audit", method: "POST", body: body)
        let response: PushResponse = try await perform(request)
        return response.inserted
    }
}

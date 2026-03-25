import Foundation
import os.log

private let logger = Logger(subsystem: "business.parlance.xcode", category: "API")

public enum ParlanceAPIError: Error, LocalizedError {
    case networkError(Error)
    case unauthorized
    case notFound
    case serverError(Int, String? = nil)
    case decodingError(Error)
    case noProjectSelected

    public var errorDescription: String? {
        switch self {
        case .networkError(let e): return "Network error: \(e.localizedDescription)"
        case .unauthorized: return "Invalid or missing API key"
        case .notFound: return "Resource not found"
        case .serverError(let code, let message):
            if let message { return "Server error (\(code)): \(message)" }
            return "Server error (\(code))"
        case .decodingError(let e): return "Failed to decode response: \(e.localizedDescription)"
        case .noProjectSelected: return "No project selected. Open the Parlance menu bar app and select a project."
        }
    }
}

// Envelope used by list endpoints: { "data": [...], "error": "..." }
private struct APIResponse<T: Decodable>: Decodable {
    let data: T?
    let error: String?
}

private struct PushResponse: Decodable {
    let inserted: Int
}

public class ParlanceAPIClient {
    private let baseURL: String
    private let apiKey: String
    private let session: URLSession

    private var clientVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    public init(apiKey: String, baseURL: String = "https://api.parlance.business") {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.session = URLSession(configuration: .default)
    }

    private func makeRequest(path: String, method: String = "GET", body: Data? = nil) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw ParlanceAPIError.networkError(URLError(.badURL))
        }
        logger.debug("\(method) \(url)")
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

    // Decodes responses wrapped in { "data": T, "error": String? }
    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, _) = try await execute(request)
        do {
            let decoded = try JSONDecoder().decode(APIResponse<T>.self, from: data)
            if let value = decoded.data { return value }
            // API returned { "data": null, "error": "..." } — surface the message
            throw ParlanceAPIError.serverError(0, decoded.error ?? "No data in response")
        } catch let e as ParlanceAPIError { throw e }
        catch { throw ParlanceAPIError.decodingError(error) }
    }

    private func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let data: Data
        let urlResponse: URLResponse
        do {
            (data, urlResponse) = try await session.data(for: request)
        } catch {
            throw ParlanceAPIError.networkError(error)
        }
        guard let http = urlResponse as? HTTPURLResponse else {
            throw ParlanceAPIError.networkError(URLError(.badServerResponse))
        }
        logger.debug("Status: \(http.statusCode)")
        switch http.statusCode {
        case 200...299: break
        case 401: throw ParlanceAPIError.unauthorized
        case 404: throw ParlanceAPIError.notFound
        default:
            let message = (try? JSONDecoder().decode(APIResponse<String>.self, from: data))?.error
            logger.error("Request failed (\(http.statusCode)): \(message ?? "unknown")")
            throw ParlanceAPIError.serverError(http.statusCode, message)
        }
        return (data, http)
    }

    public func testConnection() async throws -> Bool {
        let request = try makeRequest(path: "/api/v1/projects")
        let _: [Project] = try await perform(request)
        return true
    }

    public func fetchProjects() async throws -> [Project] {
        let request = try makeRequest(path: "/api/v1/projects")
        return try await perform(request)
    }

    public func fetchContracts(projectId: String) async throws -> [Contract] {
        let request = try makeRequest(path: "/api/v1/projects/\(projectId)/contracts")
        return try await perform(request)
    }

    public func fetchGlossary(projectId: String) async throws -> [GlossaryTerm] {
        let request = try makeRequest(path: "/api/v1/projects/\(projectId)/glossary")
        return try await perform(request)
    }

    public func pushAuditResults(projectId: String, results: [AuditResult], filePath: String) async throws -> Int {
        guard !projectId.isEmpty else {
            throw ParlanceAPIError.noProjectSelected
        }
        let payload: [String: Any] = ["results": results.map { result -> [String: String] in
            return [
                "rule_id": result.ruleId,
                "severity": result.severity.rawValue,
                "message": result.message,
                "file_path": filePath
            ]
        }]
        let body = try JSONSerialization.data(withJSONObject: payload)
        let request = try makeRequest(
            path: "/api/v1/projects/\(projectId)/audit-results",
            method: "POST",
            body: body
        )

        let data: Data
        let urlResponse: URLResponse
        do {
            (data, urlResponse) = try await session.data(for: request)
        } catch {
            throw ParlanceAPIError.networkError(error)
        }
        guard let http = urlResponse as? HTTPURLResponse else {
            throw ParlanceAPIError.networkError(URLError(.badServerResponse))
        }
        logger.debug("Push response status: \(http.statusCode)")

        switch http.statusCode {
        case 200, 201:
            do {
                return try JSONDecoder().decode(PushResponse.self, from: data).inserted
            } catch {
                throw ParlanceAPIError.decodingError(error)
            }
        case 401:
            throw ParlanceAPIError.unauthorized
        case 404:
            throw ParlanceAPIError.notFound
        default:
            let message = (try? JSONDecoder().decode(APIResponse<String>.self, from: data))?.error
            throw ParlanceAPIError.serverError(http.statusCode, message)
        }
    }
}

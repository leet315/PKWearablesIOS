import Foundation

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String
    let memberId: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case token
        case memberId = "member_id"
        case name
    }
}

struct HeartRateUploadRequest: Encodable {
    let bpm: Int
    let recordedAt: String
    let source: String

    enum CodingKeys: String, CodingKey {
        case bpm
        case recordedAt = "recorded_at"
        case source
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "The server returned an invalid response."
        case .httpStatus(let status): return "The server returned HTTP \(status)."
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    private let baseURL = URL(string: "https://www.pkmuaythai.co.uk/")!
    private let session: URLSession
    private var token: String?

    init(session: URLSession = .shared) {
        self.session = session
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        let response: LoginResponse = try await request(
            path: "auth/mobile/login",
            method: "POST",
            body: LoginRequest(email: email, password: password),
            authenticated: false
        )
        token = response.token
        return response
    }

    func uploadHeartRate(_ reading: HeartRateReading) async throws {
        let formatter = ISO8601DateFormatter()
        let requestBody = HeartRateUploadRequest(
            bpm: reading.beatsPerMinute,
            recordedAt: formatter.string(from: reading.recordedAt),
            source: reading.source
        )
        try await requestWithoutResponse(
            path: "member/health/hr",
            method: "POST",
            body: requestBody
        )
    }

    private func request<Body: Encodable, Response: Decodable>(
        path: String,
        method: String,
        body: Body,
        authenticated: Bool = true
    ) async throws -> Response {
        var request = try makeRequest(path: path, method: method, body: body, authenticated: authenticated)
        let (data, response) = try await session.data(for: request)
        try validate(response)
        return try JSONDecoder().decode(Response.self, from: data)
    }

    private func requestWithoutResponse<Body: Encodable>(
        path: String,
        method: String,
        body: Body
    ) async throws {
        let request = try makeRequest(path: path, method: method, body: body, authenticated: true)
        let (_, response) = try await session.data(for: request)
        try validate(response)
    }

    private func makeRequest<Body: Encodable>(
        path: String,
        method: String,
        body: Body,
        authenticated: Bool
    ) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if authenticated, let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    private func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.httpStatus(httpResponse.statusCode)
        }
    }
}

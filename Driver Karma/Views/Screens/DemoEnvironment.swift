import Foundation

/// TEMPORARY: demo-only! Do not deploy an app with these vars
enum DemoEnvironment {
    static let baseURL = URL(string: "http://localhost:8000")!

    static let accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhcnVka292c2tpaTQ5NzdAY29uZXN0b2dhYy5vbi5jYSIsImV4cCI6MTc5Mzc3MDcwOH0.U0BV5oojhkx0pAIcCJvR0EDIC1c6skSZQvQw2O-9dlY"

    static let client = DKAPIProdClient(DriverKarmaHTTPClient(baseURL: baseURL))
    static let configuration = DriverKarmaAPIConfiguration { accessToken }

    static func call<T>(
        _ work: (@escaping (Result<T, APIError>) -> Void) -> Void
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            work { result in
                continuation.resume(with: result.mapError { $0 as Error })
            }
        }
    }
}

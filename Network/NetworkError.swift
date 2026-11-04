import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum APIError: Error {
    case invalidURL(String)
    case requestEncodingFailed(Error)
    case transportFailed(Error)
    case timeout
    case cancelled
    case invalidResponse
    case notModified
    case unauthorized
    case forbidden
    case notFound
    case clientError(statusCode: Int, message: String?)
    case serverError(statusCode: Int, message: String?)
    case emptyResponse
    case responseDecodingFailed(Error)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL(let path):
            return "The API URL is invalid: \(path)"
        case .requestEncodingFailed(let error):
            return "The request could not be encoded. \(error.localizedDescription)"
        case .transportFailed(let error):
            return "The network request failed. \(error.localizedDescription)"
        case .timeout:
            return "The network request timed out."
        case .cancelled:
            return "The request was cancelled."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .notModified:
            return "The resource has not changed."
        case .unauthorized:
            return "Your session has expired. Please sign in again."
        case .forbidden:
            return "You do not have permission to perform this request."
        case .notFound:
            return "The requested resource was not found."
        case .clientError(let statusCode, let message):
            return message ?? "The request was rejected with status \(statusCode)."
        case .serverError(let statusCode, let message):
            return message ?? "The server failed with status \(statusCode)."
        case .emptyResponse:
            return "The server returned an empty response."
        case .responseDecodingFailed(let error):
            return "The response could not be read. \(error.localizedDescription)"
        }
    }
}

struct EmptyRequest: Encodable {}
struct EmptyResponse: Decodable {}

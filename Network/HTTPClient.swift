import Foundation

protocol APIClient {
    var http: DriverKarmaHTTPClient { get }
}

final class DKAPIProdClient: APIClient {
    let http: DriverKarmaHTTPClient
    init(_ http: DriverKarmaHTTPClient) { self.http = http }
}

final class DriverKarmaHTTPClient {
    static let api_prod = DKAPIProdClient(DriverKarmaHTTPClient(baseURL: URL(string: "https://localhost:8000")!))
    let baseURL: URL

    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let defaultHeaders: [String: String]

    init(
        baseURL: URL,
        session: URLSession = .shared,
        defaultHeaders: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.defaultHeaders = defaultHeaders
        self.encoder = encoder
        self.decoder = decoder
    }

    @discardableResult
    func send<RequestBody: Encodable, ResponseBody: Decodable>(
        path: String,
        method: HTTPMethod = .post,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: RequestBody?,
        completion: @escaping (Result<ResponseBody, APIError>) -> Void
    ) -> URLSessionDataTask? {
        let request: URLRequest

        do {
            request = try makeRequest(
                path: path,
                method: method,
                queryItems: queryItems,
                headers: headers,
                body: body
            )
        } catch let error as APIError {
            completion(.failure(error))
            return nil
        } catch {
            completion(.failure(.requestEncodingFailed(error)))
            return nil
        }

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error as NSError? {
                if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                    completion(.failure(.cancelled))
                } else {
                    completion(.failure(.transportFailed(error)))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            self.handleResponse(
                data: data ?? Data(),
                statusCode: httpResponse.statusCode,
                completion: completion
            )
        }

        task.resume()
        return task
    }

    @discardableResult
    func send<ResponseBody: Decodable>(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        completion: @escaping (Result<ResponseBody, APIError>) -> Void
    ) -> URLSessionDataTask? {
        let emptyBody: EmptyRequest? = nil
        return send(
            path: path,
            method: method,
            queryItems: queryItems,
            headers: headers,
            body: emptyBody,
            completion: completion
        )
    }

    private func makeRequest<RequestBody: Encodable>(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem],
        headers: [String: String],
        body: RequestBody?
    ) throws -> URLRequest {
        let trimmedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let url = baseURL.appendingPathComponent(trimmedPath)

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL(path)
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let finalURL = components.url else {
            throw APIError.invalidURL(path)
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30

        let rawBody = body.flatMap { $0 as? RawBodyEncodable }

        var combinedHeaders = defaultHeaders
        headers.forEach { combinedHeaders[$0.key] = $0.value }
        if body != nil && combinedHeaders["Content-Type"] == nil {
            combinedHeaders["Content-Type"] = rawBody?.contentType ?? "application/json; charset=UTF-8"
        }
        combinedHeaders.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        if let body = body {
            do {
                if let rawBody = rawBody {
                    request.httpBody = try rawBody.encodedBody()
                } else {
                    request.httpBody = try encoder.encode(body)
                }
            } catch {
                throw APIError.requestEncodingFailed(error)
            }
        }

        return request
    }

    private func handleResponse<ResponseBody: Decodable>(
        data: Data,
        statusCode: Int,
        completion: @escaping (Result<ResponseBody, APIError>) -> Void
    ) {
        switch statusCode {
        case 200...299:
            decode(data: data, completion: completion)
        case 304:
            completion(.failure(.notModified))
        case 401:
            completion(.failure(.unauthorized))
        case 403:
            completion(.failure(.forbidden))
        case 404:
            completion(.failure(.notFound))
        case 400...499:
            completion(.failure(.clientError(statusCode: statusCode, message: errorMessage(from: data))))
        case 500...599:
            completion(.failure(.serverError(statusCode: statusCode, message: errorMessage(from: data))))
        default:
            completion(.failure(.invalidResponse))
        }
    }

    private func decode<ResponseBody: Decodable>(
        data: Data,
        completion: @escaping (Result<ResponseBody, APIError>) -> Void
    ) {
        guard !data.isEmpty else {
            if let empty = EmptyResponse() as? ResponseBody {
                completion(.success(empty))
            } else {
                completion(.failure(.emptyResponse))
            }
            return
        }

        do {
            completion(.success(try decoder.decode(ResponseBody.self, from: data)))
        } catch {
            completion(.failure(.responseDecodingFailed(error)))
        }
    }

    private func errorMessage(from data: Data) -> String? {
        guard !data.isEmpty else { return nil }

        if let errorEnvelope = try? decoder.decode(APIErrorEnvelope.self, from: data) {
            return errorEnvelope.bestMessage
        }

        return String(data: data, encoding: .utf8)
    }
}

private struct APIErrorEnvelope: Decodable {
    let message: String?
    let error: String?
    let title: String?
    let detail: String?

    var bestMessage: String? {
        return message ?? detail ?? title ?? error
    }
}

/// A request body that is not JSON (form-urlencoded, multipart, ...).
/// If the body passed to `send` conforms to this, the client uses `contentType`
/// and `encodedBody()` instead of the JSONEncoder.
protocol RawBodyEncodable: Encodable {
    var contentType: String { get }
    func encodedBody() throws -> Data
}

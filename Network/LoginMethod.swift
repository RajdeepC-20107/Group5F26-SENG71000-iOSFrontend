import Foundation

final class LoginMethod {
    private let client: DKAPIProdClient

    init(client: DKAPIProdClient) {
        self.client = client
    }

    @discardableResult
    func execute(
        loginInput: DriverKarmaLoginInput,
        completion: @escaping (Result<DriverKarmaTokenResponse, APIError>) -> Void
    ) -> URLSessionDataTask? {
        return client.http.send(
            path: "/token",
            headers: ["Accept": "application/json"],
            body: loginInput
        ) { (result: Result<DriverKarmaTokenResponse, APIError>) in
            // The backend answers wrong credentials with 401, which the client maps to
            // `.unauthorized` ("Your session has expired"). Surface a login-specific message instead.
            completion(result.mapError { error in
                if case .unauthorized = error {
                    return .clientError(statusCode: 401, message: "Incorrect email or password")
                }
                return error
            })
        }
    }
}

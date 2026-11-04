import Foundation

final class GetProfileMethod {
    private let client: DKAPIProdClient
    private let configuration: DriverKarmaAPIConfiguration

    init(client: DKAPIProdClient, configuration: DriverKarmaAPIConfiguration) {
        self.client = client
        self.configuration = configuration
    }

    @discardableResult
    func execute(
        completion: @escaping (Result<DriverKarmaProfileResponse, APIError>) -> Void
    ) -> URLSessionDataTask? {
        return client.http.send(
            path: "/profile",
            headers: configuration.headers()
        ) { (result: Result<DriverKarmaProfileResponse, APIError>) in
            completion(result)
        }
    }
}

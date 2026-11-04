import Foundation

final class GetLastTrackMethod {
    private let client: DKAPIProdClient
    private let configuration: DriverKarmaAPIConfiguration

    init(client: DKAPIProdClient, configuration: DriverKarmaAPIConfiguration) {
        self.client = client
        self.configuration = configuration
    }

    @discardableResult
    func execute(
        completion: @escaping (Result<DriverKarmaTrackResponse, APIError>) -> Void
    ) -> URLSessionDataTask? {
        return client.http.send(
            path: "/track/last",
            headers: configuration.headers()
        ) { (result: Result<DriverKarmaTrackResponse, APIError>) in
            completion(result)
        }
    }
}

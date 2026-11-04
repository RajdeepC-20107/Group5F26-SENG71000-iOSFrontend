import Foundation

final class GetTrackMethod {
    private let client: DKAPIProdClient
    private let configuration: DriverKarmaAPIConfiguration

    init(client: DKAPIProdClient, configuration: DriverKarmaAPIConfiguration) {
        self.client = client
        self.configuration = configuration
    }

    @discardableResult
    func execute(
        trackID: Int,
        completion: @escaping (Result<DriverKarmaTrackResponse, APIError>) -> Void
    ) -> URLSessionDataTask? {
        return client.http.send(
            path: "/track/\(trackID)",
            headers: configuration.headers()
        ) { (result: Result<DriverKarmaTrackResponse, APIError>) in
            completion(result)
        }
    }
}

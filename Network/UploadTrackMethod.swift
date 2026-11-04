import Foundation

final class UploadTrackMethod {
    private let client: DKAPIProdClient
    private let configuration: DriverKarmaAPIConfiguration

    init(client: DKAPIProdClient, configuration: DriverKarmaAPIConfiguration) {
        self.client = client
        self.configuration = configuration
    }

    @discardableResult
    func execute(
        trackUploadInput: DriverKarmaTrackUploadInput,
        completion: @escaping (Result<DriverKarmaTrackUploadResponse, APIError>) -> Void
    ) -> URLSessionDataTask? {
        return client.http.send(
            path: "/track/upload",
            headers: configuration.headers(),
            body: trackUploadInput
        ) { (result: Result<DriverKarmaTrackUploadResponse, APIError>) in
            completion(result)
        }
    }
}

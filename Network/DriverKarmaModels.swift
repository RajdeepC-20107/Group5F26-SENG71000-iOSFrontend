import Foundation

// MARK: - Login (POST /token, application/x-www-form-urlencoded)

struct DriverKarmaLoginInput: RawBodyEncodable {
    let email: String
    let password: String

    var contentType: String { "application/x-www-form-urlencoded" }

    func encodedBody() throws -> Data {
        // FastAPI's OAuth2PasswordRequestForm expects the field to be called "username".
        let pairs = [("username", email), ("password", password)]
        let string = pairs
            .map { "\(Self.escape($0.0))=\(Self.escape($0.1))" }
            .joined(separator: "&")
        return Data(string.utf8)
    }

    // Never called: the client uses `encodedBody()` for raw bodies.
    func encode(to encoder: Encoder) throws {}

    private static let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~"))

    private static func escape(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }
}

struct DriverKarmaTokenResponse: Decodable {
    let accessToken: String
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

// MARK: - Profile (GET /profile)

struct DriverKarmaProfileResponse: Decodable {
    let email: String
    let fullName: String?
    let profileScore: Double

    enum CodingKeys: String, CodingKey {
        case email
        case fullName = "full_name"
        case profileScore = "profile_score"
    }
}

// MARK: - Track (GET /track/{track_id})

struct DriverKarmaTrackResponse: Decodable {
    let trackID: Int
    let score: Int
    let fromDate: Date
    let toDate: Date

    enum CodingKeys: String, CodingKey {
        case trackID = "track_id"
        case score
        case fromDate = "from_date"
        case toDate = "to_date"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        trackID = try container.decode(Int.self, forKey: .trackID)
        score = try container.decode(Int.self, forKey: .score)
        fromDate = try Self.decodeDate(container, .fromDate)
        toDate = try Self.decodeDate(container, .toDate)
    }

    private static func decodeDate(
        _ container: KeyedDecodingContainer<CodingKeys>,
        _ key: CodingKeys
    ) throws -> Date {
        let raw = try container.decode(String.self, forKey: key)
        guard let date = APIDateParser.date(from: raw) else {
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: container,
                debugDescription: "Unrecognized date format: \(raw)"
            )
        }
        return date
    }
}

// MARK: - Upload (POST /track/upload, multipart/form-data)

struct DriverKarmaTrackUploadInput: RawBodyEncodable {
    let fileName: String
    let fileData: Data
    let mimeType: String
    private let boundary: String

    init(fileName: String, fileData: Data, mimeType: String = "application/gpx+xml") {
        self.fileName = fileName
        self.fileData = fileData
        self.mimeType = mimeType
        self.boundary = "Boundary-\(UUID().uuidString)"
    }

    init(fileURL: URL, mimeType: String = "application/gpx+xml") throws {
        self.init(
            fileName: fileURL.lastPathComponent,
            fileData: try Data(contentsOf: fileURL),
            mimeType: mimeType
        )
    }

    var contentType: String { "multipart/form-data; boundary=\(boundary)" }

    func encodedBody() throws -> Data {
        let safeName = fileName.replacingOccurrences(of: "\"", with: "%22")
        var body = Data()
        body.append(Data("--\(boundary)\r\n".utf8))
        // Field name must be "file" to match `file: UploadFile = File(...)` on the backend.
        body.append(Data("Content-Disposition: form-data; name=\"file\"; filename=\"\(safeName)\"\r\n".utf8))
        body.append(Data("Content-Type: \(mimeType)\r\n\r\n".utf8))
        body.append(fileData)
        body.append(Data("\r\n--\(boundary)--\r\n".utf8))
        return body
    }

    // Never called: the client uses `encodedBody()` for raw bodies.
    func encode(to encoder: Encoder) throws {}
}

struct DriverKarmaTrackUploadResponse: Decodable {
    let trackID: Int
    let filename: String
    let size: Int

    enum CodingKeys: String, CodingKey {
        case trackID = "track_id"
        case filename
        case size
    }
}

// MARK: - Date parsing

/// FastAPI serializes datetimes as ISO 8601 with up to 6 fractional digits, and
/// *without* a timezone when the DB column is naive. Foundation's `.iso8601`
/// strategy handles neither, so this accepts all of those forms (naive = UTC).
enum APIDateParser {
    private static let isoFractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private static func naiveFormatter(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = format
        return f
    }

    private static let naiveFractional = naiveFormatter("yyyy-MM-dd'T'HH:mm:ss.SSS")
    private static let naive = naiveFormatter("yyyy-MM-dd'T'HH:mm:ss")

    static func date(from raw: String) -> Date? {
        // Trim microseconds to milliseconds so every formatter can parse it.
        let s = raw.replacingOccurrences(of: #"(\.\d{3})\d+"#, with: "$1", options: .regularExpression)
        return isoFractional.date(from: s)
            ?? iso.date(from: s)
            ?? naiveFractional.date(from: s)
            ?? naive.date(from: s)
    }
}

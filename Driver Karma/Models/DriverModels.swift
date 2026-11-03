import Foundation
import MapKit

struct DriverProfile {
    var fullName: String
    var address: String
    var email: String
}

struct DrivingEvent: Identifiable, Equatable {
    enum Kind: String {
        case hardBraking = "Hard braking"
        case speeding = "Speeding"
        case nightDriving = "Night Driving"
        case poorWeather = "Driving in Poor Weather"

        var symbol: String {
            switch self {
            case .hardBraking: return "exclamationmark.octagon.fill"
            case .speeding: return "speedometer"
            case .nightDriving: return "moon.circle.fill"
            case .poorWeather: return "cloud.drizzle.circle.fill"
            }
        }
    }

    let id = UUID()
    let kind: Kind
    let count: Int
}

struct DriveSession: Identifiable {
    let id = UUID()
    let date: Date
    let duration: TimeInterval
    let distanceKm: Double
    let score: Int
    let track: [CLLocationCoordinate2D]
    let events: [DrivingEvent]
}

struct LiveDriveState {
    var elapsed: TimeInterval
    var speedKmh: Int
    var speedLimitKmh: Int?
    var coordinate: CLLocationCoordinate2D
}

extension DriverProfile {
    static let preview = DriverProfile(
        fullName: "John Doe",
        address: "1 Yonge St, Toronto, ON",
        email: "jdoe@company.com"
    )
}

extension DriveSession {
    static let preview = DriveSession(
        date: Date().addingTimeInterval(-3 * 3600),
        duration: 28 * 60 + 14,
        distanceKm: 18.6,
        score: 82,
        track: CLLocationCoordinate2D.previewTrack,
        events: [
            DrivingEvent(kind: .hardBraking, count: 2),
            DrivingEvent(kind: .speeding, count: 1),
            DrivingEvent(kind: .nightDriving, count: 3),
            DrivingEvent(kind: .poorWeather, count: 0)
        ]
    )
}

extension LiveDriveState {
    static let preview = LiveDriveState(
        elapsed: 754,
        speedKmh: 62,
        speedLimitKmh: 60,
        coordinate: CLLocationCoordinate2D(latitude: 43.4643, longitude: -80.5204)
    )
}

extension CLLocationCoordinate2D {
    static let previewTrack: [CLLocationCoordinate2D] = (0..<40).map { i in
        let t = Double(i) / 39
        return CLLocationCoordinate2D(
            latitude: 43.4723 + 0.02 * t,
            longitude: -80.5449 + 0.03 * t + 0.004 * sin(t * 6)
        )
    }
}

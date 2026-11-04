import SwiftUI

/// TEMPORARY: loads real data through the method classes, then hands plain values to RootView.
///
/// The backend only returns email / full name / profile score and a track's score + start/end
/// times. It has no address, distance, events or GPS points, so those fields keep whatever the
/// template values contain (pass the same samples your previews use today).
struct DemoRootContainer: View {
    let profileTemplate: DriverProfile
    let sessionTemplate: DriveSession
    let live: LiveDriveState

    private enum Phase {
        case loading
        case loaded(profile: DriverProfile, score: Int, lastSession: DriveSession?)
        case failed(String)
    }

    @State private var phase: Phase = .loading

    var body: some View {
        Group {
            switch phase {
            case .loading:
                ProgressView("Loading…")
            case let .loaded(profile, score, lastSession):
                RootView(profile: profile,
                         overallScore: score,
                         lastSession: lastSession,
                         live: live)
            case .failed(let message):
                VStack(spacing: 12) {
                    Text(message)
                        .multilineTextAlignment(.center)
                    Button("Retry") { Task { await load() } }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .task { await load() }
    }

    @MainActor
    private func load() async {
        phase = .loading

        let profileMethod = GetProfileMethod(client: DemoEnvironment.client,
                                             configuration: DemoEnvironment.configuration)
        do {
            async let profile: DriverKarmaProfileResponse = DemoEnvironment.call {
                profileMethod.execute(completion: $0)
            }
            async let track = fetchLastTrack()

            let (profileResponse, trackResponse) = try await (profile, track)

            phase = .loaded(
                profile: profileTemplate.applying(profileResponse),
                score: Int(profileResponse.profileScore.rounded()),
                lastSession: trackResponse.map { sessionTemplate.applying($0) }
            )
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    /// 404 just means the user has no tracks yet, so it becomes `nil` instead of an error.
    private func fetchLastTrack() async throws -> DriverKarmaTrackResponse? {
        let method = GetLastTrackMethod(client: DemoEnvironment.client,
                                        configuration: DemoEnvironment.configuration)
        do {
            return try await DemoEnvironment.call { method.execute(completion: $0) }
        } catch APIError.notFound {
            return nil
        }
    }
}

// MARK: - API -> UI model mapping

extension DriverProfile {
    func applying(_ response: DriverKarmaProfileResponse) -> DriverProfile {
        var copy = self
        copy.email = response.email
        if let name = response.fullName { copy.fullName = name }
        return copy
    }
}

extension DriveSession {
    /// DriveSession's properties are `let`, so build a new value via the memberwise init.
    /// Distance, GPS track and events aren't in the API response and come from the template.
    func applying(_ response: DriverKarmaTrackResponse) -> DriveSession {
        DriveSession(
            date: response.fromDate,
            duration: response.toDate.timeIntervalSince(response.fromDate),
            distanceKm: distanceKm,
            score: response.score,
            track: track,
            events: events
        )
    }
}

#Preview {
    DemoRootContainer(profileTemplate: .preview,
                      sessionTemplate: .preview,
                      live: .preview)
}

import SwiftUI

struct SessionDetailView: View {
    let session: DriveSession
    var onSubmitAppeal: (String) -> Void

    @State private var showAppeal = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ScoreRing(score: session.score, lineWidth: 14)
                    .frame(width: 180, height: 180)
                    .padding(.top, 8)

                HStack(spacing: 12) {
                    StatTile(title: "Distance",
                             value: String(format: "%.1f km", session.distanceKm))
                    StatTile(title: "Duration", value: session.duration.clock)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("GPS track")
                        .font(.headline)
                    TrackMapView(track: session.track)
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Events")
                        .font(.headline)
                    VStack(spacing: 0) {
                        ForEach(session.events) { event in
                            HStack {
                                Image(systemName: event.kind.symbol)
                                    .frame(width: 28)
                                    .foregroundStyle(event.count == 0 ? Color.green : Color.orange)
                                Text(event.kind.rawValue)
                                Spacer()
                                Text("\(event.count)\((event.kind == .nightDriving || event.kind == .poorWeather) ? " min" : "")")
                                    .monospacedDigit()
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            if event.id != session.events.last?.id {
                                Divider().padding(.leading, 56)
                            }
                        }
                    }
                    .background(Color(.secondarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    showAppeal = true
                } label: {
                    Label("Appeal this score", systemImage: "flag")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(24)
        }
        .navigationTitle(session.date.formatted(date: .abbreviated, time: .shortened))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAppeal) {
            AppealSheet { reason in
                onSubmitAppeal(reason)
                showAppeal = false
            }
            .presentationDetents([.medium])
        }
    }
}

import SwiftUI
import MapKit

struct RecordingView: View {
    let live: LiveDriveState
    var onStop: () -> Void

    @State private var region: MKCoordinateRegion
    @State private var tracking: MapUserTrackingMode = .follow

    init(live: LiveDriveState, onStop: @escaping () -> Void) {
        self.live = live
        self.onStop = onStop
        _region = State(initialValue: MKCoordinateRegion(
            center: live.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: $tracking)
                .ignoresSafeArea()

            VStack {
                speedPanel
                Spacer()
                controlPanel
            }
            .padding()
        }
    }

    private var speedPanel: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(live.speedKmh)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text("km/h")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let limit = live.speedLimitKmh {
                Text("\(limit)")
                    .font(.title2.bold())
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(.white))
                    .overlay(Circle().stroke(.red, lineWidth: 5))
                    .foregroundStyle(.black)
                    .accessibilityLabel("Speed limit \(limit)")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private var controlPanel: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Circle().fill(.red).frame(width: 10, height: 10)
                Text("Recording")
                    .font(.subheadline.weight(.semibold))
            }
            Text(live.elapsed.clock)
                .font(.system(size: 48, weight: .semibold, design: .rounded))
                .monospacedDigit()

            Button(role: .destructive, action: onStop) {
                Label("Stop", systemImage: "stop.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .controlSize(.large)
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
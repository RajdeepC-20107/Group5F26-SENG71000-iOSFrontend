import SwiftUI

struct HomeView: View {
    let score: Int
    let lastSession: DriveSession?
    var onStartRecording: () -> Void
    var onOpenSession: () -> Void
    var onOpenProfile: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 0)

            VStack(spacing: 8) {
                Text("Your driving score")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.secondary)
                    .padding(20)
                ScoreRing(score: score)
                    .frame(width: 240, height: 240)
            }

            if let lastSession {
                Button(action: onOpenSession) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Last drive")
                                .font(.subheadline.weight(.semibold))
                            Text(lastSession.date, style: .relative)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(lastSession.score)")
                            .font(.title3.bold())
                            .foregroundStyle(lastSession.score.scoreColor)
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 0)

            Button(action: onStartRecording) {
                Label("Begin recording", systemImage: "record.circle")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(24)
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onOpenProfile) {
                    Image(systemName: "person.crop.circle")
                        .font(.title2)
                }
                .accessibilityLabel("Profile")
            }
        }
    }
}

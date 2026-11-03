import SwiftUI

struct ScoreRing: View {
    let score: Int
    var lineWidth: CGFloat = 16

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(score.scoreColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                Text("out of 100")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(lineWidth + 8)
        }
    }
}
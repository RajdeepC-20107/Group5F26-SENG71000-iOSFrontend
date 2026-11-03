import SwiftUI

extension Int {
    var scoreColor: Color {
        switch self {
        case 80...: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
}
import Foundation

extension TimeInterval {
    /// 754 -> "12:34", 4000 -> "1:06:40"
    var clock: String {
        let s = Int(self)
        let h = s / 3600, m = (s % 3600) / 60, sec = s % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, sec)
            : String(format: "%02d:%02d", m, sec)
    }
}
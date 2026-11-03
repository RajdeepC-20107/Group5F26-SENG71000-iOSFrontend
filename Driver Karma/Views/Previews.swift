import SwiftUI

#Preview("Login") {
    LoginView(onLogin: {}, onSignUp: {})
}

#Preview("Home") {
    NavigationStack {
        HomeView(score: 87,
                 lastSession: .preview,
                 onStartRecording: {},
                 onOpenSession: {},
                 onOpenProfile: {})
    }
}

#Preview("Profile") {
    NavigationStack {
        ProfileView(profile: .preview, onSave: { _ in }, onResetPassword: {})
    }
}

#Preview("Recording") {
    RecordingView(live: .preview, onStop: {})
}

#Preview("Session") {
    NavigationStack {
        SessionDetailView(session: .preview, onSubmitAppeal: { _ in })
    }
}

#Preview("Full flow") {
    RootView(profile: .preview,
             overallScore: 87,
             lastSession: .preview,
             live: .preview)
}
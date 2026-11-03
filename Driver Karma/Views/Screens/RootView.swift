import SwiftUI

struct RootView: View {
    let profile: DriverProfile
    let overallScore: Int
    let lastSession: DriveSession?
    let live: LiveDriveState

    @State private var isLoggedIn = false
    @State private var showProfile = false
    @State private var showSession = false
    @State private var showRecording = false

    var body: some View {
        if isLoggedIn {
            NavigationStack {
                HomeView(
                    score: overallScore,
                    lastSession: lastSession,
                    onStartRecording: { showRecording = true },
                    onOpenSession: { showSession = true },
                    onOpenProfile: { showProfile = true }
                )
                .navigationDestination(isPresented: $showProfile) {
                    ProfileView(profile: profile,
                                onSave: { _ in showProfile = false },
                                onResetPassword: {})
                }
                .navigationDestination(isPresented: $showSession) {
                    if let lastSession {
                        SessionDetailView(session: lastSession, onSubmitAppeal: { _ in })
                    }
                }
            }
            .fullScreenCover(isPresented: $showRecording) {
                RecordingView(live: live, onStop: { showRecording = false })
            }
        } else {
            LoginView(onLogin: { isLoggedIn = true },
                      onSignUp: { isLoggedIn = true })
        }
    }
}
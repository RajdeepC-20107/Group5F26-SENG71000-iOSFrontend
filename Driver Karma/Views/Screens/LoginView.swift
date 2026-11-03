import SwiftUI

struct LoginView: View {
    var onLogin: () -> Void
    var onSignUp: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("DriverKarma")
                .font(.largeTitle.bold())
            Spacer()

            Button(action: onLogin) {
                Text("Log in")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button(action: onSignUp) {
                Text("Sign up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding(24)
    }
}
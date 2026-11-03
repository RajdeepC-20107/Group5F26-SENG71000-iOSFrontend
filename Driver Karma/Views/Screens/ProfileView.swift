import SwiftUI

struct ProfileView: View {
    @State private var draft: DriverProfile
    @State private var showResetConfirmation = false
    var onSave: (DriverProfile) -> Void
    var onResetPassword: () -> Void

    init(profile: DriverProfile,
         onSave: @escaping (DriverProfile) -> Void,
         onResetPassword: @escaping () -> Void) {
        _draft = State(initialValue: profile)
        self.onSave = onSave
        self.onResetPassword = onResetPassword
    }

    var body: some View {
        Form {
            Section("Personal details") {
                TextField("Full name", text: $draft.fullName)
                    .textContentType(.name)
                TextField("Address", text: $draft.address, axis: .vertical)
                    .textContentType(.fullStreetAddress)
                    .lineLimit(2...4)
            }

            Section("Account") {
                HStack {
                    Text("Email")
                    Spacer()
                    Text(draft.email)
                        .foregroundStyle(.secondary)
                }
                Button("Reset password") {
                    showResetConfirmation = true
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { onSave(draft) }
            }
        }
        .alert("Reset password?", isPresented: $showResetConfirmation) {
            Button("Send reset link") { onResetPassword() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("We'll email a reset link to \(draft.email).")
        }
    }
}
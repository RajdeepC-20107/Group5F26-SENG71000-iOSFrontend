import SwiftUI

struct AppealSheet: View {
    var onSubmit: (String) -> Void
    @State private var reason = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Tell us what you think was scored incorrectly.")
                    .foregroundStyle(.secondary)
                TextEditor(text: $reason)
                    .padding(8)
                    .background(Color(.secondarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 12))
                Button {
                    onSubmit(reason)
                } label: {
                    Text("Submit appeal")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .navigationTitle("Appeal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
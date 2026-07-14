import SwiftUI

struct CodexLabSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Lab Protocol")
                        .font(LabTheme.display)
                        .foregroundStyle(LabTheme.brass)
                    Text(CodexLabMetadata.websiteHost)
                        .font(LabTheme.serif)
                        .foregroundStyle(LabTheme.label.opacity(0.7))

                    settingsRow("Privacy Policy", icon: "doc.plaintext") {
                        openURL(CodexLabMetadata.privacyPolicyURL)
                    }
                    settingsRow("Contact Us", icon: "envelope.open") {
                        openURL(CodexLabMetadata.contactUsURL)
                    }
                }
                .padding()
            }
            .labScreenStyle()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func settingsRow(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon).foregroundStyle(LabTheme.brass)
                Text(title).font(LabTheme.title).foregroundStyle(LabTheme.label)
                Spacer()
                Image(systemName: "arrow.up.right").foregroundStyle(LabTheme.brass.opacity(0.6))
            }
            .padding()
            .background(LabTheme.labGreen.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

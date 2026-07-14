import AVFoundation
import SwiftUI

struct CodexLabCameraAccessView: View {
    let prompt: String
    @State private var authorized = CodexLabISBNScannerEngine.authorizationStatus == .authorized
    @State private var denied = CodexLabISBNScannerEngine.authorizationStatus == .denied

    var body: some View {
        Group {
            if authorized {
                EmptyView()
            } else if denied {
                VStack(spacing: 16) {
                    Image(systemName: "camera.fill").font(.largeTitle).foregroundStyle(LabTheme.brass)
                    Text("Camera access required")
                        .font(LabTheme.serif).foregroundStyle(LabTheme.label)
                    Text(prompt)
                        .font(LabTheme.serif).foregroundStyle(LabTheme.label.opacity(0.75))
                        .multilineTextAlignment(.center)
                    Button("Open Settings") { openSettings() }
                        .font(LabTheme.serif).foregroundStyle(LabTheme.labGreenDark)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(LabTheme.brass).clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.92))
            } else {
                ProgressView("Requesting camera access…")
                    .font(LabTheme.serif)
                    .tint(LabTheme.brass)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.92))
                    .task {
                        let granted = await CodexLabISBNScannerEngine.ensureCameraAuthorized()
                        authorized = granted
                        denied = !granted
                    }
            }
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

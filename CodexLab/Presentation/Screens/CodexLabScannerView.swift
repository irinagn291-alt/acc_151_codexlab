import AVFoundation
import SwiftUI

struct CodexLabScannerView: View {
    let onScan: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var manualISBN = ""
    @State private var showManual = false
    @State private var cameraReady = CodexLabISBNScannerEngine.authorizationStatus == .authorized

    var body: some View {
        ZStack {
            LabTheme.labGreenDark.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                titleBlock
                viewfinder
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                Text("Center the ISBN barcode in the frame to load a new specimen.")
                    .font(.system(size: 14, design: .serif))
                    .foregroundStyle(LabTheme.label.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .padding(.top, 16)
                Spacer(minLength: 12)
                Button("Enter ISBN manually") { showManual = true }
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .foregroundStyle(LabTheme.brass)
                    .padding(.bottom, 28)
            }

            if !cameraReady {
                CodexLabCameraAccessView(prompt: CodexLabMetadata.cameraPrompt)
            }
        }
        .preferredColorScheme(.dark)
        .alert("Enter ISBN", isPresented: $showManual) {
            TextField("978...", text: $manualISBN)
                .keyboardType(.numbersAndPunctuation)
            Button("Load") {
                if let isbn = CodexLabISBNScannerEngine.normalizedISBN(from: manualISBN) {
                    onScan(isbn)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .task {
            cameraReady = await CodexLabISBNScannerEngine.ensureCameraAuthorized()
        }
    }

    private var topBar: some View {
        HStack {
            Button("Close") { dismiss() }
                .font(.system(size: 16, design: .serif))
                .foregroundStyle(LabTheme.label)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var titleBlock: some View {
        VStack(spacing: 6) {
            Text("Load specimen")
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundStyle(LabTheme.label)
            Text(CodexLabMetadata.cameraPrompt)
                .font(.system(size: 14, design: .serif))
                .foregroundStyle(LabTheme.brass.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
    }

    private var viewfinder: some View {
        ZStack {
            if cameraReady {
                CodexLabBarcodeScannerRepresentable { isbn in
                    onScan(isbn)
                    dismiss()
                }
            } else {
                LabTheme.ink.opacity(0.5)
            }

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(LabTheme.brass, lineWidth: 2.5)
                .padding(26)
                .allowsHitTesting(false)

            VStack {
                Spacer()
                Text("ISBN / barcode")
                    .font(.system(size: 12, weight: .semibold, design: .serif))
                    .foregroundStyle(LabTheme.ink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(LabTheme.brass)
                    .clipShape(Capsule())
                    .padding(.bottom, 18)
            }
            .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 420)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(LabTheme.brass.opacity(0.45), lineWidth: 1)
        )
    }
}

struct CodexLabBarcodeScannerRepresentable: UIViewControllerRepresentable {
    let onDetect: (String) -> Void

    func makeUIViewController(context: Context) -> SpecimenCaptureRig {
        let controller = CodexLabISBNScannerEngine.makeCaptureController()
        controller.onDetect = onDetect
        return controller
    }

    func updateUIViewController(_ uiViewController: SpecimenCaptureRig, context: Context) {}
}

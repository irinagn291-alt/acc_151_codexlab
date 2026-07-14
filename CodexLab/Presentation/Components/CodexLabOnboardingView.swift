import SwiftUI

struct CodexLabOnboardingView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            LabTheme.labGreenDark.ignoresSafeArea()
            VStack(spacing: 18) {
                Text("Open the laboratory")
                    .font(.system(.title, design: .rounded).bold())
                    .foregroundStyle(LabTheme.brass)
                Text("Genres form a periodic table. Specimens react as you read. Monthly alchemy tracks two-genre hypotheses.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.85))
                Button("Load first specimen") {
                    UserDefaults.standard.set(true, forKey: "codexlab.onboarded.v1")
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .tint(LabTheme.brass)
            }
            .padding()
        }
    }
}

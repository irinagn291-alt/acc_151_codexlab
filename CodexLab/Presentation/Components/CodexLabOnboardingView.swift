import SwiftUI

struct CodexLabOnboardingView: View {
    @Binding var isPresented: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var litIndex = 0
    @State private var boil = false
    @State private var step = 0

    private let demo: [(symbol: String, name: String)] = [
        ("Gh", "Horror"), ("Sf", "Sci-Fi"), ("My", "Mystery"),
        ("Fa", "Fantasy"), ("Th", "Thriller"), ("Hi", "History")
    ]

    private let lectures: [(title: String, body: String)] = [
        ("Genres are elements", "The periodic table is your lab bench. Each cell is a genre reagent — open a specimen drawer to load work."),
        ("Pages drive reactions", "Logging pages heats purity. Idle experiments cool. Watch phase shift from idle → heating → reacting → precipitate."),
        ("Alchemy needs two reagents", "Monthly hypotheses bind two genres. Hit the page target and the bench yields a measured result.")
    ]

    var body: some View {
        ZStack {
            LabTheme.screenBackground
            VStack(spacing: 20) {
                Text("CODEX LAB")
                    .font(LabTheme.display)
                    .foregroundStyle(LabTheme.brass)
                    .padding(.top, 36)

                miniTable
                    .padding(.horizontal, 20)

                vialRow
                    .padding(.vertical, 8)

                VStack(spacing: 10) {
                    Text(lectures[step].title)
                        .font(LabTheme.title)
                        .foregroundStyle(LabTheme.brass)
                        .multilineTextAlignment(.center)
                    Text(lectures[step].body)
                        .font(LabTheme.serif)
                        .foregroundStyle(LabTheme.label.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .id(step)
                .transition(.opacity)

                Spacer()

                HStack(spacing: 8) {
                    ForEach(0..<lectures.count, id: \.self) { i in
                        Circle()
                            .fill(i == step ? LabTheme.brass : LabTheme.label.opacity(0.25))
                            .frame(width: 8, height: 8)
                    }
                }

                Button(action: advance) {
                    Text(step < lectures.count - 1 ? "Next reaction" : "Load first specimen")
                        .font(.system(.body, design: .serif).weight(.semibold))
                        .foregroundStyle(LabTheme.labGreenDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(LabTheme.brass)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 28)
                .padding(.bottom, 36)
            }
        }
        .onAppear { startReactionLoop() }
    }

    private var miniTable: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
            ForEach(Array(demo.enumerated()), id: \.offset) { index, item in
                VStack(spacing: 4) {
                    Text(item.symbol)
                        .font(.system(.title3, design: .serif).weight(.bold))
                        .foregroundStyle(index == litIndex ? LabTheme.labGreenDark : LabTheme.brass)
                    Text(item.name)
                        .font(.system(size: 11, design: .serif))
                        .foregroundStyle(LabTheme.label.opacity(0.8))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, minHeight: 64)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(index == litIndex ? LabTheme.brass.opacity(0.95) : LabTheme.labGreen.opacity(0.45))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(LabTheme.brass.opacity(0.7), lineWidth: 1)
                )
                .scaleEffect(index == litIndex && !reduceMotion ? 1.04 : 1)
            }
        }
    }

    private var vialRow: some View {
        HStack(spacing: 18) {
            ForEach(0..<3, id: \.self) { i in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(LabTheme.brass.opacity(0.5), lineWidth: 1)
                        .frame(width: 36, height: 72)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(LabTheme.vialGreen.opacity(0.55 + Double(i) * 0.1))
                        .frame(width: 28, height: boil ? CGFloat(28 + i * 10) : CGFloat(18 + i * 8))
                        .padding(.bottom, 4)
                }
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: boil)
    }

    private func startReactionLoop() {
        boil = true
        guard !reduceMotion else { return }
        Task { @MainActor in
            while !Task.isCancelled && isPresented {
                try? await Task.sleep(nanoseconds: 900_000_000)
                withAnimation(.easeInOut(duration: 0.35)) {
                    litIndex = (litIndex + 1) % demo.count
                }
            }
        }
    }

    private func advance() {
        if step < lectures.count - 1 {
            withAnimation { step += 1 }
        } else {
            UserDefaults.standard.set(true, forKey: "codexlab.onboarded.v2")
            isPresented = false
        }
    }
}

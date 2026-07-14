import SwiftUI

struct BubblingReactionCanvas: View {
    let phase: ReactionPhase
    var progress: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var bubblePhase = false

    private var fillRatio: CGFloat {
        CGFloat(max(0.08, min(0.92, max(progress, phaseFill(phase)))))
    }

    var body: some View {
        GeometryReader { geo in
            let w = min(geo.size.width * 0.38, 88)
            let h = geo.size.height * 0.78
            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(LabTheme.ink.opacity(0.4))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: liquidColors(phase),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(height: max(h * 0.1, h * fillRatio))

                if (phase == .heating || phase == .reacting) && !reduceMotion {
                    ForEach(0..<5, id: \.self) { i in
                        Circle()
                            .fill(Color.white.opacity(0.35))
                            .frame(width: CGFloat(2 + i % 3), height: CGFloat(2 + i % 3))
                            .offset(
                                x: CGFloat((i % 3) - 1) * w * 0.16,
                                y: bubblePhase ? -h * fillRatio * 0.55 : -h * fillRatio * 0.2
                            )
                    }
                    .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: bubblePhase)
                }

                Capsule()
                    .stroke(LabTheme.brass, lineWidth: 2)
            }
            .frame(width: w, height: h)
            .clipShape(Capsule())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear { bubblePhase = true }
        }
    }

    private func phaseFill(_ phase: ReactionPhase) -> Double {
        switch phase {
        case .idle: 0.12
        case .heating: 0.35
        case .reacting: 0.62
        case .precipitated: 0.88
        }
    }

    private func liquidColors(_ phase: ReactionPhase) -> [Color] {
        switch phase {
        case .idle:
            [LabTheme.glass, LabTheme.vialGreen.opacity(0.45)]
        case .heating:
            [LabTheme.copper.opacity(0.65), LabTheme.brass.opacity(0.75)]
        case .reacting:
            [LabTheme.vialGreen, LabTheme.brass.opacity(0.7)]
        case .precipitated:
            [LabTheme.vialGreen.opacity(0.95), LabTheme.brass]
        }
    }
}

struct MolecularConnectionsView: View {
    let elements: [GenreElement]
    let positions: [UUID: CGPoint]

    var body: some View {
        Canvas { context, _ in
            for element in elements {
                guard let from = positions[element.id] else { continue }
                for related in element.relatedElementIDs {
                    guard let to = positions[related], related.uuidString > element.id.uuidString else { continue }
                    var path = Path()
                    path.move(to: from)
                    let mid = CGPoint(
                        x: (from.x + to.x) / 2,
                        y: min(from.y, to.y) - 18
                    )
                    path.addQuadCurve(to: to, control: mid)
                    context.stroke(
                        path,
                        with: .color(LabTheme.vialGreen.opacity(0.45)),
                        style: StrokeStyle(lineWidth: 1.2, dash: [4, 3])
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct SpecimenInsertionEffect: ViewModifier {
    let active: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(active ? 1 : 0.4)
            .opacity(active ? 1 : 0)
            .offset(y: active ? 0 : 24)
            .animation(.spring(response: 0.45, dampingFraction: 0.72), value: active)
    }
}

struct SpecimenVialOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let w = min(geo.size.width * 0.55, 220)
            let h = w * 1.55
            ZStack {
                Capsule()
                    .stroke(LabTheme.brass, lineWidth: 3)
                    .frame(width: w, height: h)
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LabTheme.copper.opacity(0.85))
                        .frame(width: w * 0.42, height: 16)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    LabTheme.vialGreen.opacity(0.15),
                                    LabTheme.vialGreen.opacity(0.45)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: w * 0.72, height: h * 0.55)
                        .padding(.top, 8)
                }
                Text("Load specimen vial")
                    .font(.system(.footnote, design: .serif).weight(.semibold))
                    .foregroundStyle(LabTheme.label)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(LabTheme.ink.opacity(0.7))
                    .clipShape(Capsule())
                    .offset(y: h * 0.42)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .allowsHitTesting(false)
    }
}

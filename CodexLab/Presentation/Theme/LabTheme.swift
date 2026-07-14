import SwiftUI

enum LabTheme {
    static let brass = Color(red: 0.72, green: 0.53, blue: 0.24)
    static let copper = Color(red: 0.72, green: 0.45, blue: 0.20)
    static let labGreen = Color(red: 0.12, green: 0.22, blue: 0.18)
    static let labGreenDark = Color(red: 0.06, green: 0.12, blue: 0.10)
    static let vialGreen = Color(red: 0.28, green: 0.62, blue: 0.42)
    static let glass = Color(red: 0.85, green: 0.92, blue: 0.88).opacity(0.15)
    static let label = Color(red: 0.9, green: 0.88, blue: 0.82)
    static let ink = Color(red: 0.08, green: 0.14, blue: 0.12)
    static let serif = Font.system(.body, design: .serif)
    static let title = Font.system(.title2, design: .serif).weight(.semibold)
    static let display = Font.system(.largeTitle, design: .serif).weight(.bold)

    @ViewBuilder
    static var screenBackground: some View {
        ZStack {
            LinearGradient(
                colors: [LabTheme.labGreen, LabTheme.labGreenDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Canvas { context, size in
                for i in 0..<18 {
                    let x = CGFloat((i * 47) % Int(size.width))
                    let y = CGFloat((i * 73) % Int(size.height))
                    let r = CGFloat(40 + (i % 5) * 12)
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                        with: .color(LabTheme.brass.opacity(0.03))
                    )
                }
            }
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

struct LabBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            LabTheme.screenBackground
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(LabTheme.labGreen)
    }
}

extension View {
    func labBackground() -> some View {
        modifier(LabBackgroundModifier())
    }

    func labScreenStyle() -> some View {
        self
            .scrollContentBackground(.hidden)
            .toolbarBackground(LabTheme.labGreen, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .labBackground()
    }
}

struct Octagon: Shape {
    func path(in rect: CGRect) -> Path {
        let inset = min(rect.width, rect.height) * 0.18
        var path = Path()
        let points: [CGPoint] = [
            CGPoint(x: rect.minX + inset, y: rect.minY),
            CGPoint(x: rect.maxX - inset, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.minY + inset),
            CGPoint(x: rect.maxX, y: rect.maxY - inset),
            CGPoint(x: rect.maxX - inset, y: rect.maxY),
            CGPoint(x: rect.minX + inset, y: rect.maxY),
            CGPoint(x: rect.minX, y: rect.maxY - inset),
            CGPoint(x: rect.minX, y: rect.minY + inset)
        ]
        path.move(to: points[0])
        for p in points.dropFirst() { path.addLine(to: p) }
        path.closeSubpath()
        return path
    }
}

struct BrassFrame<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LabTheme.ink.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(LabTheme.brass.opacity(0.85), lineWidth: 1.5)
            )
    }
}

struct GaugeMeter: View {
    let value: Double
    var title: String = ""
    var unit: String = "%"
    var compact: Bool = false

    @State private var animated = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 4 : 8) {
            if !title.isEmpty {
                Text(title.uppercased())
                    .font(.system(size: compact ? 10 : 11, weight: .semibold, design: .serif))
                    .foregroundStyle(LabTheme.brass.opacity(0.9))
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(Int(animated * 100))")
                    .font(.system(size: compact ? 22 : 28, weight: .semibold, design: .serif))
                    .foregroundStyle(LabTheme.label)
                    .monospacedDigit()
                Text(unit)
                    .font(.system(size: compact ? 11 : 13, design: .serif))
                    .foregroundStyle(LabTheme.brass)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(LabTheme.glass)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [LabTheme.vialGreen, LabTheme.brass],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(6, geo.size.width * animated))
                }
            }
            .frame(height: compact ? 5 : 7)
        }
        .padding(compact ? 10 : 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LabTheme.ink.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(LabTheme.brass.opacity(0.45), lineWidth: 1)
        )
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                animated = min(max(value, 0), 1)
            }
        }
        .onChange(of: value) { _, newValue in
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                animated = min(max(newValue, 0), 1)
            }
        }
    }
}

import SwiftUI

struct AlchemyBenchView: View {
    @State private var viewModel = AlchemyBenchViewModel()
    @State private var liquidLevel: CGFloat = 0.2

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Text("Alchemy Bench")
                    .font(LabTheme.display)
                    .foregroundStyle(LabTheme.brass)
                Text("Monthly hypothesis · two genres · track pages")
                    .font(LabTheme.serif)
                    .foregroundStyle(LabTheme.label.opacity(0.8))

                flaskPair

                BrassFrame {
                    VStack(alignment: .leading, spacing: 14) {
                        genrePicker("Genre A", selection: $viewModel.genreA)
                        genrePicker("Genre B", selection: $viewModel.genreB)
                        Text("Target pages")
                            .font(.caption)
                            .foregroundStyle(LabTheme.brass)
                        HStack(spacing: 8) {
                            ForEach([100, 250, 500, 1000], id: \.self) { pages in
                                Button {
                                    viewModel.targetPages = pages
                                } label: {
                                    Text("\(pages)")
                                        .font(.system(size: 14, weight: .semibold, design: .serif))
                                        .foregroundStyle(viewModel.targetPages == pages ? LabTheme.ink : LabTheme.label)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(viewModel.targetPages == pages ? LabTheme.brass : LabTheme.glass)
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        Button {
                            Task { await viewModel.create() }
                        } label: {
                            Label(viewModel.hypothesis == nil ? "Seal hypothesis" : "Replace incomplete", systemImage: "lock.rectangle.stack")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(BrassButtonStyle())
                        .disabled(viewModel.isSaving)
                    }
                }

                if let hypothesis = viewModel.hypothesis {
                    progressCard(hypothesis)
                }

                if let message = viewModel.message {
                    Text(message)
                        .font(LabTheme.serif)
                        .foregroundStyle(LabTheme.copper)
                }
            }
            .padding()
        }
        .navigationTitle("Alchemy")
        .labScreenStyle()
        .task {
            await viewModel.load()
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                liquidLevel = viewModel.hypothesis?.progress ?? 0.2
            }
        }
        .onChange(of: viewModel.hypothesis?.progressPages) { _, _ in
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                liquidLevel = viewModel.hypothesis?.progress ?? liquidLevel
            }
        }
    }

    private var flaskPair: some View {
        HStack(alignment: .bottom, spacing: 16) {
            flask(label: viewModel.genreA, fill: 0.35)
            Text("+")
                .font(LabTheme.title)
                .foregroundStyle(LabTheme.brass)
                .padding(.bottom, 28)
            flask(label: viewModel.genreB, fill: 0.35)
            Text("=")
                .font(LabTheme.title)
                .foregroundStyle(LabTheme.brass)
                .padding(.bottom, 28)
            VStack(spacing: 6) {
                vial(width: 64, height: 96, fill: max(0.12, liquidLevel), tint: LabTheme.vialGreen)
                Text("Rx")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(LabTheme.brass)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func flask(label: String, fill: CGFloat) -> some View {
        VStack(spacing: 6) {
            vial(width: 52, height: 80, fill: fill, tint: LabTheme.glass)
            Text(ReagentCodeMapper.prefix(for: label))
                .font(.caption.weight(.bold))
                .foregroundStyle(LabTheme.brass)
        }
    }

    private func vial(width: CGFloat, height: CGFloat, fill: CGFloat, tint: Color) -> some View {
        let level = min(max(fill, 0), 1)
        return ZStack(alignment: .bottom) {
            Capsule()
                .fill(LabTheme.ink.opacity(0.35))
            Capsule()
                .fill(tint)
                .frame(height: max(height * 0.12, height * level))
            Capsule()
                .stroke(LabTheme.brass, lineWidth: 2)
        }
        .frame(width: width, height: height)
        .clipShape(Capsule())
    }

    private func genrePicker(_ title: String, selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(LabTheme.brass)
            Picker(title, selection: selection) {
                ForEach(viewModel.availableGenres, id: \.self) { genre in
                    Text(genre).tag(genre)
                }
            }
            .pickerStyle(.menu)
            .tint(LabTheme.brass)
        }
    }

    private func progressCard(_ hypothesis: Hypothesis) -> some View {
        BrassFrame {
            VStack(alignment: .leading, spacing: 10) {
                Text("\(hypothesis.monthKey)")
                    .font(.caption.monospaced())
                    .foregroundStyle(LabTheme.brass)
                Text("\(hypothesis.genreA) × \(hypothesis.genreB)")
                    .font(LabTheme.title)
                    .foregroundStyle(LabTheme.label)
                GaugeMeter(value: hypothesis.progress, title: "Monthly yield", unit: "%")
                Text("\(hypothesis.progressPages) / \(hypothesis.targetPages) pages")
                    .font(LabTheme.serif)
                    .foregroundStyle(LabTheme.label.opacity(0.85))
                if hypothesis.isComplete {
                    Text("Hypothesis precipitated")
                        .font(LabTheme.serif.weight(.semibold))
                        .foregroundStyle(LabTheme.vialGreen)
                }
                Button("Refresh progress") {
                    Task { await viewModel.refreshProgress() }
                }
                .buttonStyle(BrassButtonStyle(filled: false))
            }
        }
    }
}

import SwiftUI

struct LaboratoryWorkspaceView: View {
    @Bindable var coordinator: CodexLabCoordinator
    @State private var viewModel: LaboratoryWorkspaceViewModel

    init(coordinator: CodexLabCoordinator) {
        self.coordinator = coordinator
        _viewModel = State(initialValue: LaboratoryWorkspaceViewModel(bookId: coordinator.selectedBookID))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            Group {
                if let book = viewModel.book {
                    specimenDesk(book)
                } else {
                    Text("Select a specimen from the periodic table.")
                        .font(LabTheme.serif)
                        .foregroundStyle(LabTheme.label.opacity(0.75))
                        .padding(.top, 48)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .navigationTitle("Laboratory")
        .navigationBarTitleDisplayMode(.inline)
        .labScreenStyle()
        .task { await viewModel.load() }
        .onChange(of: coordinator.selectedBookID) { _, _ in
            viewModel = LaboratoryWorkspaceViewModel(bookId: coordinator.selectedBookID)
            Task { await viewModel.load() }
        }
    }

    private func specimenDesk(_ book: CodexLabBook) -> some View {
        VStack(spacing: 22) {
            HStack(alignment: .center, spacing: 18) {
                CodexLabBookCoverImage(
                    book: book,
                    width: 120,
                    height: 180,
                    cornerRadius: 6,
                    placeholderFill: LabTheme.ink.opacity(0.5),
                    placeholderIconColor: LabTheme.brass
                )
                .shadow(color: .black.opacity(0.35), radius: 16, y: 8)

                BubblingReactionCanvas(phase: book.reactionPhase, progress: book.progress)
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(LabTheme.brass.opacity(0.45), lineWidth: 1)
                    )
            }
            .padding(.top, 8)

            VStack(spacing: 6) {
                Text(book.title)
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundStyle(LabTheme.label)
                    .multilineTextAlignment(.center)
                Text(book.author)
                    .font(.system(size: 15, design: .serif))
                    .foregroundStyle(LabTheme.brass)
                Text("\(book.reagentCode) · \(book.reactionPhase.label)")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(LabTheme.label.opacity(0.55))
            }

            phaseTrack(book.reactionPhase)

            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(LabTheme.ink.opacity(0.45))
                        Capsule()
                            .fill(LabTheme.vialGreen)
                            .frame(width: max(8, geo.size.width * book.progress))
                    }
                }
                .frame(height: 10)
                HStack {
                    Text("\(Int(book.progress * 100))% yield")
                        .font(.system(size: 14, weight: .semibold, design: .serif))
                        .foregroundStyle(LabTheme.label)
                    Spacer()
                    Text("\(book.currentPage) / \(book.totalPages) pages")
                        .font(.system(size: 13, design: .serif))
                        .foregroundStyle(LabTheme.label.opacity(0.6))
                }
                Text("Purity \(Int(book.purity))%")
                    .font(.system(size: 12, design: .serif))
                    .foregroundStyle(LabTheme.brass)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Dose")
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundStyle(LabTheme.brass)
                HStack(spacing: 8) {
                    ForEach([5, 10, 25, 50], id: \.self) { pages in
                        Button {
                            viewModel.pagesToLog = pages
                        } label: {
                            Text("+\(pages)")
                                .font(.system(size: 15, weight: .semibold, design: .serif))
                                .foregroundStyle(viewModel.pagesToLog == pages ? LabTheme.ink : LabTheme.label)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(viewModel.pagesToLog == pages ? LabTheme.brass : LabTheme.ink.opacity(0.35))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    Task { await viewModel.logPagesAction() }
                } label: {
                    Text("Run reaction  ·  +\(viewModel.pagesToLog) pages")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BrassButtonStyle())

                Button {
                    Task { await viewModel.advancePhaseAction() }
                } label: {
                    Text(book.reactionPhase == .precipitated ? "Precipitate sealed" : "Advance phase → \(book.reactionPhase.next.label)")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BrassButtonStyle(filled: false))
                .disabled(book.reactionPhase == .precipitated || viewModel.isAdvancing)

                CodexLabViewAtSourceButton(url: book.openLibrarySourceURL)
                    .font(.system(size: 14, design: .serif))
                    .foregroundStyle(LabTheme.brass)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
            }
        }
    }

    private func phaseTrack(_ phase: ReactionPhase) -> some View {
        HStack(spacing: 0) {
            ForEach(ReactionPhase.allCases, id: \.self) { step in
                VStack(spacing: 6) {
                    Circle()
                        .fill(stepIndex(step) <= stepIndex(phase) ? LabTheme.vialGreen : LabTheme.ink.opacity(0.45))
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(LabTheme.brass.opacity(0.5), lineWidth: 1))
                    Text(step.label)
                        .font(.system(size: 10, design: .serif))
                        .foregroundStyle(step == phase ? LabTheme.brass : LabTheme.label.opacity(0.4))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity)
                if step != ReactionPhase.allCases.last {
                    Rectangle()
                        .fill(stepIndex(step) < stepIndex(phase) ? LabTheme.vialGreen.opacity(0.7) : LabTheme.brass.opacity(0.25))
                        .frame(height: 1)
                        .offset(y: -8)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func stepIndex(_ phase: ReactionPhase) -> Int {
        ReactionPhase.allCases.firstIndex(of: phase) ?? 0
    }
}

struct BrassButtonStyle: ButtonStyle {
    var filled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LabTheme.serif.weight(.semibold))
            .foregroundStyle(filled ? LabTheme.ink : LabTheme.brass)
            .padding(.vertical, 14)
            .background(filled ? LabTheme.brass : LabTheme.glass)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(LabTheme.brass, lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

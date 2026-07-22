import SwiftUI

struct PeriodicTableCanvasView: View {
    @Bindable var coordinator: CodexLabCoordinator
    @State private var viewModel = PeriodicTableViewModel()
    @State private var cellFrames: [UUID: CGRect] = [:]
    @State private var appeared = false

    var body: some View {
        GeometryReader { geo in
            let columns = gridColumns(for: geo.size.width)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    ZStack {
                        MolecularConnectionsView(
                            elements: viewModel.elements,
                            positions: connectionPoints(in: geo.size)
                        )
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(viewModel.elements) { element in
                                elementCell(element)
                                    .background(
                                        GeometryReader { cellGeo in
                                            Color.clear.preference(
                                                key: ElementFrameKey.self,
                                                value: [element.id: cellGeo.frame(in: .named("table"))]
                                            )
                                        }
                                    )
                            }
                        }
                    }
                    .coordinateSpace(name: "table")
                    .onPreferenceChange(ElementFrameKey.self) { cellFrames = $0 }
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .navigationTitle(CodexLabMetadata.name)
        .toolbar { toolbarContent }
        .task {
            await viewModel.load()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { appeared = true }
        }
        .sheet(isPresented: $coordinator.showSpecimenDrawer) {
            if let id = coordinator.selectedElementID,
               let element = viewModel.element(id: id) {
                SpecimenDrawerView(element: element, coordinator: coordinator)
            }
        }
    }

    private func gridColumns(for width: CGFloat) -> [GridItem] {
        let count = width < 420 ? 3 : (width < 700 ? 4 : 6)
        return Array(repeating: GridItem(.flexible(minimum: 96), spacing: 10), count: count)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Periodic Table")
                .font(LabTheme.display)
                .foregroundStyle(LabTheme.brass)
            Text(CodexLabMetadata.tagline)
                .font(LabTheme.serif)
                .foregroundStyle(LabTheme.label.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private func elementCell(_ element: GenreElement) -> some View {
        Button {
            coordinator.navigate(to: .specimenDrawer(element.id))
        } label: {
            BrassFrame {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top, spacing: 6) {
                        Text(element.symbol)
                            .font(.system(.title3, design: .serif).weight(.bold))
                            .foregroundStyle(LabTheme.labGreenDark)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(LabTheme.brass.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        Spacer(minLength: 0)
                        Text("\(element.atomicNumber)")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(LabTheme.label.opacity(0.6))
                    }
                    Text(element.name)
                        .font(.system(size: 12, design: .serif).weight(.semibold))
                        .foregroundStyle(LabTheme.label)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    specimenDots(element)
                }
                .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
            }
        }
        .buttonStyle(.plain)
        .modifier(SpecimenInsertionEffect(active: appeared))
    }

    private func specimenDots(_ element: GenreElement) -> some View {
        HStack(spacing: 4) {
            ForEach(element.specimens.prefix(6)) { book in
                Circle()
                    .fill(dotColor(for: book.reactionPhase))
                    .frame(width: 8, height: 8)
                    .overlay(Circle().stroke(LabTheme.brass.opacity(0.6), lineWidth: 0.5))
                    .accessibilityLabel(book.title)
            }
            if element.specimenCount > 6 {
                Text("+\(element.specimenCount - 6)")
                    .font(.system(size: 9, design: .serif))
                    .foregroundStyle(LabTheme.brass)
            }
            if element.specimenCount == 0 {
                Text("empty")
                    .font(.system(size: 9, design: .serif))
                    .foregroundStyle(LabTheme.label.opacity(0.4))
            }
        }
    }

    private func dotColor(for phase: ReactionPhase) -> Color {
        switch phase {
        case .idle: LabTheme.glass
        case .heating: LabTheme.copper
        case .reacting: LabTheme.vialGreen
        case .precipitated: LabTheme.brass
        }
    }

    private func connectionPoints(in size: CGSize) -> [UUID: CGPoint] {
        Dictionary(uniqueKeysWithValues: cellFrames.map { id, frame in
            (id, CGPoint(x: frame.midX, y: frame.midY))
        })
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button { coordinator.navigate(to: .laboratoryWorkspace) } label: {
                Image(systemName: "gauge.open.with.lines.needle.33percent")
            }
            Button { coordinator.navigate(to: .experimentLog) } label: {
                Image(systemName: "list.bullet.rectangle")
            }
            Button { coordinator.navigate(to: .alchemyBench) } label: {
                Image(systemName: "flask.fill")
            }
            Button { coordinator.navigate(to: .scanner) } label: {
                Image(systemName: "barcode.viewfinder")
            }
            Button { coordinator.navigate(to: .settings) } label: {
                Image(systemName: "gearshape")
            }
            .accessibilityLabel("Settings")
        }
    }
}

struct SpecimenDrawerView: View {
    let element: GenreElement
    @Bindable var coordinator: CodexLabCoordinator
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(element.symbol)
                            .font(LabTheme.display)
                            .foregroundStyle(LabTheme.brass)
                        VStack(alignment: .leading) {
                            Text(element.name).font(LabTheme.title).foregroundStyle(LabTheme.label)
                            Text("Prefix \(element.reagentPrefix) · \(element.specimenCount) specimens")
                                .font(LabTheme.serif)
                                .foregroundStyle(LabTheme.label.opacity(0.7))
                        }
                    }
                    ForEach(element.specimens) { book in
                        VStack(alignment: .leading, spacing: 8) {
                            Button {
                                coordinator.openSpecimen(book.id)
                                dismiss()
                            } label: {
                                HStack(spacing: 12) {
                                    CodexLabBookCoverImage(
                                        book: book,
                                        width: 44,
                                        height: 66,
                                        cornerRadius: 4,
                                        placeholderFill: LabTheme.ink.opacity(0.5),
                                        placeholderIconColor: LabTheme.brass
                                    )
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(book.title)
                                            .font(LabTheme.serif)
                                            .foregroundStyle(LabTheme.label)
                                            .multilineTextAlignment(.leading)
                                        Text("\(book.reagentCode) · \(book.reactionPhase.label)")
                                            .font(.caption)
                                            .foregroundStyle(LabTheme.brass)
                                        ProgressView(value: book.progress)
                                            .tint(LabTheme.vialGreen)
                                    }
                                    Spacer(minLength: 0)
                                    Text("\(Int(book.progress * 100))%")
                                        .font(.system(size: 13, weight: .semibold, design: .serif))
                                        .foregroundStyle(LabTheme.label)
                                        .monospacedDigit()
                                }
                            }
                            .buttonStyle(.plain)
                            CodexLabViewAtSourceButton(url: book.openLibrarySourceURL, title: "Open Library")
                                .font(.caption)
                                .foregroundStyle(LabTheme.brass)
                        }
                        .padding(12)
                        .background(LabTheme.ink.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(LabTheme.brass.opacity(0.45), lineWidth: 1)
                        )
                    }
                    if element.specimens.isEmpty {
                        Text("No specimens in this cell yet. Load a vial to begin.")
                            .font(LabTheme.serif)
                            .foregroundStyle(LabTheme.label.opacity(0.7))
                            .padding(.top, 24)
                    }
                }
                .padding()
            }
            .labScreenStyle()
            .navigationTitle("Specimen Drawer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct ElementFrameKey: PreferenceKey {
    static var defaultValue: [UUID: CGRect] = [:]
    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

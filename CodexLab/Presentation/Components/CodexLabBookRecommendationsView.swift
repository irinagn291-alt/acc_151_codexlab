import SwiftUI

struct CodexLabBookRecommendationsView: View {
    private let cardWidth: CGFloat = 110
    private let coverWidth: CGFloat = 90
    private let coverHeight: CGFloat = 130
    private let cardHeight: CGFloat = 218

    var onBookAdded: () -> Void = {}
    @State private var feed: CodexLabRecommendationFeed?
    @State private var addingID: String?
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let feed {
                if !feed.curated.isEmpty {
                    recommendationSection(CodexLabMetadata.curatedTitle, subtitle: "Based on your library", items: feed.curated)
                }
                if !feed.discover.isEmpty {
                    recommendationSection(CodexLabMetadata.discoverTitle, subtitle: "From Open Library", items: feed.discover)
                }
            } else {
                HStack {
                    ProgressView().tint(LabTheme.brass)
                    Text("Loading specimens…").font(LabTheme.serif).foregroundStyle(LabTheme.label.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(LabTheme.glass)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .task { feed = await CodexLabFactory.shared.fetchBookRecommendationsUseCase.execute() }
        .alert("Could not add book", isPresented: .init(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func recommendationSection(_ title: String, subtitle: String, items: [CodexLabBookRecommendation]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(LabTheme.title).foregroundStyle(LabTheme.brass)
                Text(subtitle).font(LabTheme.serif).foregroundStyle(LabTheme.label.opacity(0.5))
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(items) { item in
                        recommendationCard(item)
                    }
                }
            }
        }
        .padding()
        .background(LabTheme.glass)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func recommendationCard(_ item: CodexLabBookRecommendation) -> some View {
        Button { Task { await add(item) } } label: {
            VStack(alignment: .leading, spacing: 6) {
                CodexLabOpenLibraryCoverImage(
                    urls: item.coverURLs,
                    width: coverWidth,
                    height: coverHeight,
                    cornerRadius: 6,
                    placeholderFill: LabTheme.labGreen.opacity(0.3),
                    placeholderIconColor: LabTheme.brass.opacity(0.5)
                )

                Text(item.title)
                    .font(LabTheme.serif)
                    .foregroundStyle(LabTheme.label)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(width: cardWidth, height: 34, alignment: .topLeading)

                Text(item.author)
                    .font(.caption2)
                    .foregroundStyle(LabTheme.copper)
                    .lineLimit(1)
                    .frame(width: cardWidth, height: 14, alignment: .topLeading)

                Text(metaLine(item))
                    .font(.caption2)
                    .foregroundStyle(LabTheme.label.opacity(0.4))
                    .lineLimit(1)
                    .frame(width: cardWidth, height: 14, alignment: .topLeading)

                Text("Add specimen")
                    .font(.caption2)
                    .foregroundStyle(LabTheme.brass)
                    .frame(width: cardWidth, height: 14, alignment: .topLeading)
            }
            .frame(width: cardWidth, height: cardHeight, alignment: .topLeading)
        }
        .buttonStyle(.plain)
        .disabled(addingID != nil)
    }

    private func metaLine(_ item: CodexLabBookRecommendation) -> String {
        if let year = item.publishYear {
            return "\(year) · \(item.subject)"
        }
        return item.subject
    }

    private func add(_ item: CodexLabBookRecommendation) async {
        guard item.isbn != nil || !item.isbnCandidates.isEmpty else { return }
        addingID = item.id
        defer { addingID = nil }
        do {
            _ = try await CodexLabFactory.shared.addBookUseCase.execute(recommendation: item)
            feed = await CodexLabFactory.shared.fetchBookRecommendationsUseCase.execute()
            onBookAdded()
        } catch {
            errorMessage = "Could not fetch book from Open Library"
        }
    }
}

#Preview { CodexLabBookRecommendationsView().labScreenStyle() }

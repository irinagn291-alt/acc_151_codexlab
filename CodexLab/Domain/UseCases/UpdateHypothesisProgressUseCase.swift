import Foundation

struct UpdateHypothesisProgressUseCase: Sendable {
    private let labRepository: CodexLabLabRepositoryProtocol
    private let bookRepository: CodexLabBookRepositoryProtocol

    init(labRepository: CodexLabLabRepositoryProtocol, bookRepository: CodexLabBookRepositoryProtocol) {
        self.labRepository = labRepository
        self.bookRepository = bookRepository
    }

    func execute(monthKey: String? = nil) async throws -> Hypothesis? {
        let key = monthKey ?? Hypothesis.monthKey()
        guard var hypothesis = try await labRepository.fetchHypothesis(monthKey: key) else { return nil }

        let books = try await bookRepository.fetchAll()
        let relevantIDs = Set(books.filter { book in
            ReagentCodeMapper.matches(book.genre, elementName: hypothesis.genreA)
                || ReagentCodeMapper.matches(book.genre, elementName: hypothesis.genreB)
        }.map(\.id))

        let sessions = try await bookRepository.fetchSessions(for: nil)
        let calendar = Calendar.current
        guard let monthDate = monthDate(from: key, calendar: calendar),
              let interval = calendar.dateInterval(of: .month, for: monthDate) else {
            return hypothesis
        }

        let pages = sessions
            .filter { relevantIDs.contains($0.bookId) && $0.date >= interval.start && $0.date < interval.end }
            .reduce(0) { $0 + $1.pagesRead }

        hypothesis.progressPages = pages
        hypothesis.isComplete = pages >= hypothesis.targetPages
        try await labRepository.updateHypothesis(hypothesis)
        return hypothesis
    }

    private func monthDate(from key: String, calendar: Calendar) -> Date? {
        let parts = key.split(separator: "-")
        guard parts.count == 2,
              let year = Int(parts[0]),
              let month = Int(parts[1]) else { return nil }
        return calendar.date(from: DateComponents(year: year, month: month, day: 1))
    }
}

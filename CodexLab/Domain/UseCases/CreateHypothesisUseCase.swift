import Foundation

struct CreateHypothesisUseCase: Sendable {
    private let labRepository: CodexLabLabRepositoryProtocol

    nonisolated init(labRepository: CodexLabLabRepositoryProtocol) {
        self.labRepository = labRepository
    }

    nonisolated func execute(genreA: String, genreB: String, targetPages: Int, date: Date = Date()) async throws -> Hypothesis {
        let a = genreA.trimmingCharacters(in: .whitespacesAndNewlines)
        let b = genreB.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !a.isEmpty, !b.isEmpty, a.caseInsensitiveCompare(b) != .orderedSame else {
            throw CodexLabDomainError.invalidHypothesis
        }
        guard targetPages > 0 else { throw CodexLabDomainError.invalidHypothesis }

        let month = Hypothesis.monthKey(for: date)
        if let existing = try await labRepository.fetchHypothesis(monthKey: month), !existing.isComplete {
            throw CodexLabDomainError.hypothesisExists
        }

        let hypothesis = Hypothesis(
            id: UUID(),
            genreA: a,
            genreB: b,
            targetPages: targetPages,
            progressPages: 0,
            monthKey: month,
            createdAt: date,
            isComplete: false
        )
        try await labRepository.saveHypothesis(hypothesis)
        return hypothesis
    }
}

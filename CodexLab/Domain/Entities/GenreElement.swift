import Foundation

nonisolated struct GenreElement: Identifiable, Equatable, Sendable {
    let id: UUID
    let symbol: String
    let name: String
    let reagentPrefix: String
    var specimenCount: Int
    var atomicNumber: Int
    var relatedElementIDs: [UUID]
    var specimens: [CodexLabBook]

    var atomicWeight: Int { max(specimenCount, 1) * 10 }

    static let catalogSeed: [(symbol: String, name: String, prefix: String, atomic: Int)] = [
        ("Gh", "Horror", "Gh", 1),
        ("Sf", "Science Fiction", "Sf", 2),
        ("My", "Mystery", "My", 3),
        ("Fa", "Fantasy", "Fa", 4),
        ("Ro", "Romance", "Ro", 5),
        ("Th", "Thriller", "Th", 6),
        ("Hi", "History", "Hi", 7),
        ("Bi", "Biography", "Bi", 8),
        ("Ad", "Adventure", "Ad", 9),
        ("Po", "Poetry", "Po", 10),
        ("Dr", "Drama", "Dr", 11),
        ("Nf", "Nonfiction", "Nf", 12)
    ]
}

import Foundation

enum CodexLabMetadata {
    static let name = "Codex Lab"
    static let tagline = "Every book is a reagent. Every page an experiment."
    static let version = "2.0.0-lab"
    static let seedKey = "com.codexlab.didSeed.v4"
    static let cameraPrompt = "Load specimen vial barcode for analysis"
    static let leadChemist = "Dr. Codex"
    static let unit = "molecules"
    static let recommendationSubjects = ["horror", "science_fiction", "mystery"]
    static let curatedTitle = "Reagent Picks"
    static let discoverTitle = "Open Library Specimens"
    static let websiteHost = "reagenthq-specimen.pro"
    static var privacyPolicyURL: URL { URL(string: "https://\(websiteHost)/privacy-policy")! }
    static var contactUsURL: URL { URL(string: "https://\(websiteHost)/contact-us")! }
}

enum ReactionPhase: String, CaseIterable, Sendable, Codable, Hashable {
    case idle
    case heating
    case reacting
    case precipitated

    nonisolated var next: ReactionPhase {
        switch self {
        case .idle: .heating
        case .heating: .reacting
        case .reacting: .precipitated
        case .precipitated: .precipitated
        }
    }

    nonisolated var label: String {
        switch self {
        case .idle: "Idle"
        case .heating: "Heating"
        case .reacting: "Reacting"
        case .precipitated: "Precipitated"
        }
    }
}

enum ReagentCodeMapper: Sendable {
    nonisolated static func prefix(for genre: String) -> String {
        let g = genre.lowercased()
        if g.contains("horror") || g.contains("gothic") { return "Gh" }
        if g.contains("sci") || g.contains("science") || g.contains("sf") { return "Sf" }
        if g.contains("mystery") || g.contains("detective") || g.contains("crime") { return "My" }
        if g.contains("fantasy") { return "Fa" }
        if g.contains("romance") { return "Ro" }
        if g.contains("history") || g.contains("historical") { return "Hi" }
        if g.contains("thriller") { return "Th" }
        if g.contains("biography") || g.contains("memoir") { return "Bi" }
        let letters = genre.filter(\.isLetter)
        guard letters.count >= 2 else { return "Rx" }
        return String(letters.prefix(2)).capitalized
    }

    nonisolated static func code(for genre: String, salt: Int? = nil) -> String {
        let n = salt ?? Int.random(in: 10...99)
        return "\(prefix(for: genre))-\(String(format: "%02d", n % 100))"
    }

    nonisolated static func matches(_ genre: String, elementName: String) -> Bool {
        let g = genre.lowercased()
        let e = elementName.lowercased()
        if e == "horror" { return g.contains("horror") || g.contains("gothic") }
        if e == "scifi" || e == "science fiction" {
            return g.contains("sci") || g.contains("science") || g.contains("sf")
        }
        if e == "mystery" { return g.contains("mystery") || g.contains("detective") || g.contains("crime") }
        return g.contains(e) || e.contains(g)
    }
}

nonisolated struct CodexLabBook: Identifiable, Equatable, Sendable {
    let id: UUID
    let isbn: String
    var title: String
    var author: String
    var coverURL: URL?
    var genre: String
    var totalPages: Int
    var currentPage: Int
    let dateAdded: Date
    var isActive: Bool
    var flavorMeta: String
    var reactionPhase: ReactionPhase
    var purity: Double
    var reagentCode: String

    var progress: Double {
        guard totalPages > 0 else { return 0 }
        return min(Double(currentPage) / Double(totalPages), 1.0)
    }

    var boilingPoint: Int { totalPages / 10 + currentPage / 5 }
    var yieldPercent: Double { progress * 100 }
}

nonisolated struct CodexLabReadingSession: Identifiable, Equatable, Sendable {
    let id: UUID
    let bookId: UUID
    let date: Date
    var pagesRead: Int
    var duration: TimeInterval
    var flavorMeta: String
}

nonisolated struct CodexLabReadingStats: Sendable {
    var currentStreak: Int
    var bestStreak: Int
    var totalPages: Int
    var pagesThisWeek: Int
    var averagePagesPerSession: Double
    var consistencyScore: Int
    var dailyPages: [Date: Int]
}

struct CodexLabOpenLibraryBook: Decodable, Sendable {
    let title: String?
    let authors: [String]?
    let numberOfPages: Int?
    let subjects: [String]?
    let workKey: String?
    let editionKey: String?
    let coverId: Int?

    enum CodingKeys: String, CodingKey {
        case title, authors, subjects
        case numberOfPages = "number_of_pages"
        case workKey, editionKey, coverId
    }
}

nonisolated struct CodexLabBookRecommendation: Identifiable, Equatable, Sendable {
    let id: String
    let isbn: String?
    let isbnCandidates: [String]
    let workKey: String?
    let coverId: Int?
    let coverURLs: [URL]
    let title: String
    let author: String
    let subject: String
    let publishYear: Int?

    var coverURL: URL? { coverURLs.first }
}

struct CodexLabRecommendationFeed: Sendable {
    var curated: [CodexLabBookRecommendation]
    var discover: [CodexLabBookRecommendation]
}

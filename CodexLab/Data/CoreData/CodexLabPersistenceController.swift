import CoreData

enum CodexLabPersistenceController {
    static let shared = makeController(storeName: "CodexLab")

    static func makeController(storeName: String) -> NSPersistentContainer {
        let model = Self.makeModel()
        if let disk = load(storeName: storeName, model: model, inMemory: false) {
            return disk
        }
        if let memory = load(storeName: storeName, model: model, inMemory: true) {
            return memory
        }
        assertionFailure("CodexLab persistence unavailable")
        let fallback = NSPersistentContainer(name: storeName, managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        fallback.persistentStoreDescriptions = [description]
        fallback.loadPersistentStores { _, _ in }
        fallback.viewContext.automaticallyMergesChangesFromParent = true
        return fallback
    }

    private static func load(storeName: String, model: NSManagedObjectModel, inMemory: Bool) -> NSPersistentContainer? {
        let container = NSPersistentContainer(name: storeName, managedObjectModel: model)
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        var loadError: Error?
        let group = DispatchGroup()
        group.enter()
        container.loadPersistentStores { _, error in
            loadError = error
            group.leave()
        }
        _ = group.wait(timeout: .now() + 5)
        guard loadError == nil else { return nil }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        func attr(_ n: String, _ t: NSAttributeType, opt: Bool = false) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name = n
            a.attributeType = t
            a.isOptional = opt
            return a
        }

        let bookEntity = NSEntityDescription()
        bookEntity.name = "CodexLabBookEntity"
        bookEntity.managedObjectClassName = "CodexLabBookEntity"
        bookEntity.properties = [
            attr("id", .UUIDAttributeType),
            attr("isbn", .stringAttributeType),
            attr("title", .stringAttributeType),
            attr("author", .stringAttributeType),
            attr("coverURLString", .stringAttributeType, opt: true),
            attr("genre", .stringAttributeType),
            attr("totalPages", .integer32AttributeType),
            attr("currentPage", .integer32AttributeType),
            attr("dateAdded", .dateAttributeType),
            attr("isActive", .booleanAttributeType),
            attr("flavorMeta", .stringAttributeType, opt: true),
            attr("reactionPhase", .stringAttributeType),
            attr("purity", .doubleAttributeType),
            attr("reagentCode", .stringAttributeType)
        ]

        let sessionEntity = NSEntityDescription()
        sessionEntity.name = "CodexLabSessionEntity"
        sessionEntity.managedObjectClassName = "CodexLabSessionEntity"
        sessionEntity.properties = [
            attr("id", .UUIDAttributeType),
            attr("bookId", .UUIDAttributeType),
            attr("date", .dateAttributeType),
            attr("pagesRead", .integer32AttributeType),
            attr("duration", .doubleAttributeType),
            attr("flavorMeta", .stringAttributeType, opt: true)
        ]

        let experimentEntity = NSEntityDescription()
        experimentEntity.name = "ExperimentEntity"
        experimentEntity.managedObjectClassName = "ExperimentEntity"
        experimentEntity.properties = [
            attr("id", .UUIDAttributeType),
            attr("bookId", .UUIDAttributeType),
            attr("title", .stringAttributeType),
            attr("startedAt", .dateAttributeType),
            attr("phase", .stringAttributeType),
            attr("yieldValue", .doubleAttributeType),
            attr("temperature", .integer32AttributeType),
            attr("isArchived", .booleanAttributeType)
        ]

        let reactionEntity = NSEntityDescription()
        reactionEntity.name = "ReactionEntity"
        reactionEntity.managedObjectClassName = "ReactionEntity"
        reactionEntity.properties = [
            attr("id", .UUIDAttributeType),
            attr("experimentId", .UUIDAttributeType, opt: true),
            attr("bookId", .UUIDAttributeType),
            attr("date", .dateAttributeType),
            attr("pagesRead", .integer32AttributeType),
            attr("phase", .stringAttributeType),
            attr("note", .stringAttributeType),
            attr("puritySnapshot", .doubleAttributeType)
        ]

        let hypothesisEntity = NSEntityDescription()
        hypothesisEntity.name = "HypothesisEntity"
        hypothesisEntity.managedObjectClassName = "HypothesisEntity"
        hypothesisEntity.properties = [
            attr("id", .UUIDAttributeType),
            attr("genreA", .stringAttributeType),
            attr("genreB", .stringAttributeType),
            attr("targetPages", .integer32AttributeType),
            attr("progressPages", .integer32AttributeType),
            attr("monthKey", .stringAttributeType),
            attr("createdAt", .dateAttributeType),
            attr("isComplete", .booleanAttributeType)
        ]

        let genreElementEntity = NSEntityDescription()
        genreElementEntity.name = "GenreElementEntity"
        genreElementEntity.managedObjectClassName = "GenreElementEntity"
        genreElementEntity.properties = [
            attr("id", .UUIDAttributeType),
            attr("symbol", .stringAttributeType),
            attr("name", .stringAttributeType),
            attr("reagentPrefix", .stringAttributeType),
            attr("specimenCount", .integer32AttributeType),
            attr("atomicNumber", .integer32AttributeType),
            attr("relatedIDsData", .binaryDataAttributeType, opt: true)
        ]

        model.entities = [
            bookEntity,
            sessionEntity,
            experimentEntity,
            reactionEntity,
            hypothesisEntity,
            genreElementEntity
        ]
        return model
    }
}

@objc(CodexLabBookEntity)
final class CodexLabBookEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var isbn: String?
    @NSManaged var title: String?
    @NSManaged var author: String?
    @NSManaged var coverURLString: String?
    @NSManaged var genre: String?
    @NSManaged var totalPages: Int32
    @NSManaged var currentPage: Int32
    @NSManaged var dateAdded: Date?
    @NSManaged var isActive: Bool
    @NSManaged var flavorMeta: String?
    @NSManaged var reactionPhase: String?
    @NSManaged var purity: Double
    @NSManaged var reagentCode: String?

    nonisolated func toDomain() -> CodexLabBook? {
        guard let id, let isbn, let title, let author, let genre, let dateAdded else { return nil }
        let phase = ReactionPhase(rawValue: reactionPhase ?? "") ?? .idle
        let code = reagentCode ?? flavorMeta ?? ReagentCodeMapper.code(for: genre, salt: 1)
        return CodexLabBook(
            id: id,
            isbn: isbn,
            title: title,
            author: author,
            coverURL: coverURLString.flatMap(URL.init(string:)),
            genre: genre,
            totalPages: Int(totalPages),
            currentPage: Int(currentPage),
            dateAdded: dateAdded,
            isActive: isActive,
            flavorMeta: flavorMeta ?? code,
            reactionPhase: phase,
            purity: purity,
            reagentCode: code
        )
    }

    nonisolated func apply(_ book: CodexLabBook) {
        id = book.id
        isbn = book.isbn
        title = book.title
        author = book.author
        coverURLString = book.coverURL?.absoluteString
        genre = book.genre
        totalPages = Int32(book.totalPages)
        currentPage = Int32(book.currentPage)
        dateAdded = book.dateAdded
        isActive = book.isActive
        flavorMeta = book.flavorMeta
        reactionPhase = book.reactionPhase.rawValue
        purity = book.purity
        reagentCode = book.reagentCode
    }
}

@objc(CodexLabSessionEntity)
final class CodexLabSessionEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var bookId: UUID?
    @NSManaged var date: Date?
    @NSManaged var pagesRead: Int32
    @NSManaged var duration: Double
    @NSManaged var flavorMeta: String?

    nonisolated func toDomain() -> CodexLabReadingSession? {
        guard let id, let bookId, let date else { return nil }
        return CodexLabReadingSession(
            id: id,
            bookId: bookId,
            date: date,
            pagesRead: Int(pagesRead),
            duration: duration,
            flavorMeta: flavorMeta ?? ""
        )
    }
}

@objc(ExperimentEntity)
final class ExperimentEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var bookId: UUID?
    @NSManaged var title: String?
    @NSManaged var startedAt: Date?
    @NSManaged var phase: String?
    @NSManaged var yieldValue: Double
    @NSManaged var temperature: Int32
    @NSManaged var isArchived: Bool

    nonisolated func toDomain() -> Experiment? {
        guard let id, let bookId, let title, let startedAt else { return nil }
        return Experiment(
            id: id,
            bookId: bookId,
            title: title,
            startedAt: startedAt,
            phase: ReactionPhase(rawValue: phase ?? "") ?? .idle,
            yield: yieldValue,
            temperature: Int(temperature),
            isArchived: isArchived
        )
    }

    nonisolated func apply(_ experiment: Experiment) {
        id = experiment.id
        bookId = experiment.bookId
        title = experiment.title
        startedAt = experiment.startedAt
        phase = experiment.phase.rawValue
        yieldValue = experiment.yield
        temperature = Int32(experiment.temperature)
        isArchived = experiment.isArchived
    }
}

@objc(ReactionEntity)
final class ReactionEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var experimentId: UUID?
    @NSManaged var bookId: UUID?
    @NSManaged var date: Date?
    @NSManaged var pagesRead: Int32
    @NSManaged var phase: String?
    @NSManaged var note: String?
    @NSManaged var puritySnapshot: Double

    nonisolated func toDomain() -> Reaction? {
        guard let id, let bookId, let date else { return nil }
        return Reaction(
            id: id,
            experimentId: experimentId,
            bookId: bookId,
            date: date,
            pagesRead: Int(pagesRead),
            phase: ReactionPhase(rawValue: phase ?? "") ?? .idle,
            note: note ?? "",
            puritySnapshot: puritySnapshot
        )
    }

    nonisolated func apply(_ reaction: Reaction) {
        id = reaction.id
        experimentId = reaction.experimentId
        bookId = reaction.bookId
        date = reaction.date
        pagesRead = Int32(reaction.pagesRead)
        phase = reaction.phase.rawValue
        note = reaction.note
        puritySnapshot = reaction.puritySnapshot
    }
}

@objc(HypothesisEntity)
final class HypothesisEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var genreA: String?
    @NSManaged var genreB: String?
    @NSManaged var targetPages: Int32
    @NSManaged var progressPages: Int32
    @NSManaged var monthKey: String?
    @NSManaged var createdAt: Date?
    @NSManaged var isComplete: Bool

    nonisolated func toDomain() -> Hypothesis? {
        guard let id, let genreA, let genreB, let monthKey, let createdAt else { return nil }
        return Hypothesis(
            id: id,
            genreA: genreA,
            genreB: genreB,
            targetPages: Int(targetPages),
            progressPages: Int(progressPages),
            monthKey: monthKey,
            createdAt: createdAt,
            isComplete: isComplete
        )
    }

    nonisolated func apply(_ hypothesis: Hypothesis) {
        id = hypothesis.id
        genreA = hypothesis.genreA
        genreB = hypothesis.genreB
        targetPages = Int32(hypothesis.targetPages)
        progressPages = Int32(hypothesis.progressPages)
        monthKey = hypothesis.monthKey
        createdAt = hypothesis.createdAt
        isComplete = hypothesis.isComplete
    }
}

@objc(GenreElementEntity)
final class GenreElementEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var symbol: String?
    @NSManaged var name: String?
    @NSManaged var reagentPrefix: String?
    @NSManaged var specimenCount: Int32
    @NSManaged var atomicNumber: Int32
    @NSManaged var relatedIDsData: Data?

    nonisolated func toDomain() -> GenreElement? {
        guard let id, let symbol, let name, let reagentPrefix else { return nil }
        var related: [UUID] = []
        if let relatedIDsData,
           let decoded = try? JSONDecoder().decode([UUID].self, from: relatedIDsData) {
            related = decoded
        }
        return GenreElement(
            id: id,
            symbol: symbol,
            name: name,
            reagentPrefix: reagentPrefix,
            specimenCount: Int(specimenCount),
            atomicNumber: Int(atomicNumber),
            relatedElementIDs: related,
            specimens: []
        )
    }

    nonisolated func apply(_ element: GenreElement) {
        id = element.id
        symbol = element.symbol
        name = element.name
        reagentPrefix = element.reagentPrefix
        specimenCount = Int32(element.specimenCount)
        atomicNumber = Int32(element.atomicNumber)
        relatedIDsData = try? JSONEncoder().encode(element.relatedElementIDs)
    }
}

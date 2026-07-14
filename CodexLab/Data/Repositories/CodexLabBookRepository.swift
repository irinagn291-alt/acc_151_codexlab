import CoreData

final class CodexLabBookRepository: CodexLabBookRepositoryProtocol, @unchecked Sendable {
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
    }

    private var context: NSManagedObjectContext { container.viewContext }

    func fetchAll() async throws -> [CodexLabBook] {
        try await perform {
            let request = NSFetchRequest<CodexLabBookEntity>(entityName: "CodexLabBookEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
            return try self.context.fetch(request).compactMap { $0.toDomain() }
        }
    }

    func fetchActive() async throws -> CodexLabBook? {
        try await perform {
            let request = NSFetchRequest<CodexLabBookEntity>(entityName: "CodexLabBookEntity")
            request.predicate = NSPredicate(format: "isActive == YES")
            request.fetchLimit = 1
            return try self.context.fetch(request).first?.toDomain()
        }
    }

    func fetch(by id: UUID) async throws -> CodexLabBook? {
        try await perform {
            let request = NSFetchRequest<CodexLabBookEntity>(entityName: "CodexLabBookEntity")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            return try self.context.fetch(request).first?.toDomain()
        }
    }

    func save(_ book: CodexLabBook) async throws {
        try await perform {
            let entity = CodexLabBookEntity(context: self.context)
            entity.apply(book)
            try self.context.save()
        }
    }

    func setActive(_ bookId: UUID) async throws {
        try await perform {
            let all = NSFetchRequest<CodexLabBookEntity>(entityName: "CodexLabBookEntity")
            let books = try self.context.fetch(all)
            books.forEach { $0.isActive = ($0.id == bookId) }
            try self.context.save()
        }
    }

    func updateProgress(bookId: UUID, currentPage: Int) async throws {
        try await perform {
            let request = NSFetchRequest<CodexLabBookEntity>(entityName: "CodexLabBookEntity")
            request.predicate = NSPredicate(format: "id == %@", bookId as CVarArg)
            guard let entity = try self.context.fetch(request).first else { return }
            entity.currentPage = Int32(currentPage)
            try self.context.save()
        }
    }

    func updateBook(_ book: CodexLabBook) async throws {
        try await perform {
            let request = NSFetchRequest<CodexLabBookEntity>(entityName: "CodexLabBookEntity")
            request.predicate = NSPredicate(format: "id == %@", book.id as CVarArg)
            guard let entity = try self.context.fetch(request).first else { return }
            entity.apply(book)
            try self.context.save()
        }
    }

    func logSession(_ session: CodexLabReadingSession) async throws {
        try await perform {
            let entity = CodexLabSessionEntity(context: self.context)
            entity.id = session.id
            entity.bookId = session.bookId
            entity.date = session.date
            entity.pagesRead = Int32(session.pagesRead)
            entity.duration = session.duration
            entity.flavorMeta = session.flavorMeta
            try self.context.save()
        }
    }

    func fetchSessions(for bookId: UUID?) async throws -> [CodexLabReadingSession] {
        try await perform {
            let request = NSFetchRequest<CodexLabSessionEntity>(entityName: "CodexLabSessionEntity")
            if let bookId {
                request.predicate = NSPredicate(format: "bookId == %@", bookId as CVarArg)
            }
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            return try self.context.fetch(request).compactMap { $0.toDomain() }
        }
    }

    func fetchSessions(from start: Date, to end: Date) async throws -> [CodexLabReadingSession] {
        try await perform {
            let request = NSFetchRequest<CodexLabSessionEntity>(entityName: "CodexLabSessionEntity")
            request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", start as NSDate, end as NSDate)
            return try self.context.fetch(request).compactMap { $0.toDomain() }
        }
    }

    private func perform<T>(_ work: @escaping () throws -> T) async throws -> T {
        try await context.perform {
            try work()
        }
    }
}

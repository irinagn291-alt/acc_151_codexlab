import CoreData

final class CodexLabLabRepository: CodexLabLabRepositoryProtocol, @unchecked Sendable {
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
    }

    nonisolated func fetchExperiments() async throws -> [Experiment] {
        try await perform { context in
            let request = NSFetchRequest<ExperimentEntity>(entityName: "ExperimentEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "startedAt", ascending: false)]
            return try context.fetch(request).compactMap { $0.toDomain() }
        }
    }

    nonisolated func fetchExperiment(by id: UUID) async throws -> Experiment? {
        try await perform { context in
            let request = NSFetchRequest<ExperimentEntity>(entityName: "ExperimentEntity")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            return try context.fetch(request).first?.toDomain()
        }
    }

    nonisolated func saveExperiment(_ experiment: Experiment) async throws {
        try await perform { context in
            let entity = ExperimentEntity(context: context)
            entity.apply(experiment)
            try context.save()
        }
    }

    nonisolated func updateExperiment(_ experiment: Experiment) async throws {
        try await perform { context in
            let request = NSFetchRequest<ExperimentEntity>(entityName: "ExperimentEntity")
            request.predicate = NSPredicate(format: "id == %@", experiment.id as CVarArg)
            guard let entity = try context.fetch(request).first else { return }
            entity.apply(experiment)
            try context.save()
        }
    }

    nonisolated func fetchReactions() async throws -> [Reaction] {
        try await perform { context in
            let request = NSFetchRequest<ReactionEntity>(entityName: "ReactionEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            return try context.fetch(request).compactMap { $0.toDomain() }
        }
    }

    nonisolated func saveReaction(_ reaction: Reaction) async throws {
        try await perform { context in
            let entity = ReactionEntity(context: context)
            entity.apply(reaction)
            try context.save()
        }
    }

    nonisolated func fetchHypotheses() async throws -> [Hypothesis] {
        try await perform { context in
            let request = NSFetchRequest<HypothesisEntity>(entityName: "HypothesisEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            return try context.fetch(request).compactMap { $0.toDomain() }
        }
    }

    nonisolated func fetchHypothesis(monthKey: String) async throws -> Hypothesis? {
        try await perform { context in
            let request = NSFetchRequest<HypothesisEntity>(entityName: "HypothesisEntity")
            request.predicate = NSPredicate(format: "monthKey == %@", monthKey)
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            request.fetchLimit = 1
            return try context.fetch(request).first?.toDomain()
        }
    }

    nonisolated func saveHypothesis(_ hypothesis: Hypothesis) async throws {
        try await perform { context in
            let entity = HypothesisEntity(context: context)
            entity.apply(hypothesis)
            try context.save()
        }
    }

    nonisolated func updateHypothesis(_ hypothesis: Hypothesis) async throws {
        try await perform { context in
            let request = NSFetchRequest<HypothesisEntity>(entityName: "HypothesisEntity")
            request.predicate = NSPredicate(format: "id == %@", hypothesis.id as CVarArg)
            guard let entity = try context.fetch(request).first else { return }
            entity.apply(hypothesis)
            try context.save()
        }
    }

    nonisolated func fetchGenreElements() async throws -> [GenreElement] {
        try await perform { context in
            let request = NSFetchRequest<GenreElementEntity>(entityName: "GenreElementEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "atomicNumber", ascending: true)]
            return try context.fetch(request).compactMap { $0.toDomain() }
        }
    }

    nonisolated func saveGenreElements(_ elements: [GenreElement]) async throws {
        try await perform { context in
            let existing = NSFetchRequest<GenreElementEntity>(entityName: "GenreElementEntity")
            let old = try context.fetch(existing)
            old.forEach { context.delete($0) }
            for element in elements {
                let entity = GenreElementEntity(context: context)
                entity.apply(element)
            }
            try context.save()
        }
    }

    private nonisolated func perform<T: Sendable>(_ work: @escaping @Sendable (NSManagedObjectContext) throws -> T) async throws -> T {
        let context = container.viewContext
        return try await context.perform {
            try work(context)
        }
    }
}

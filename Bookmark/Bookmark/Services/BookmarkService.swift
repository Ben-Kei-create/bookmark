import CoreData
import Foundation

enum BookmarkService {
    static func create(
        url: String,
        title: String,
        description: String,
        in context: NSManagedObjectContext
    ) throws {
        let existing = try fetchByURL(url, in: context)
        if existing != nil { throw BookmarkError.duplicateURL }

        let normalized = URLValidator.normalizeURL(url)
        let bookmarkTitle = title.trimmingCharacters(in: .whitespaces).isEmpty
            ? URLValidator.extractDomain(from: normalized)
            : title

        _ = BookmarkEntity.makeNew(
            url: normalized,
            title: bookmarkTitle,
            description: description,
            in: context
        )
        try context.save()
    }

    static func update(
        _ entity: BookmarkEntity,
        title: String,
        description: String,
        in context: NSManagedObjectContext
    ) throws {
        try entity.update(title: title, description: description, in: context)
    }

    static func delete(_ entity: BookmarkEntity, in context: NSManagedObjectContext) throws {
        try entity.softDelete(in: context)
    }

    private static func fetchByURL(_ url: String, in context: NSManagedObjectContext) throws -> BookmarkEntity? {
        let request = BookmarkEntity.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "url == %@", url),
            NSPredicate(format: "isArchived == false")
        ])
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

enum BookmarkError: LocalizedError {
    case duplicateURL
    case notFound

    var errorDescription: String? {
        switch self {
        case .duplicateURL: return AppStrings.duplicateURL
        case .notFound: return "Bookmark not found"
        }
    }
}

import CoreData
import Foundation

class BookmarkService {
    static let shared = BookmarkService()
    private let coreDataManager = CoreDataManager.shared

    func createBookmark(
        url: String,
        title: String,
        description: String,
        in context: NSManagedObjectContext
    ) throws -> Bookmark {
        let entity = BookmarkEntity.makeNewBookmark(
            url: url,
            title: title,
            description: description,
            in: context
        )
        try coreDataManager.save(context: context)
        return Bookmark(from: entity)
    }

    func updateBookmark(
        _ bookmark: Bookmark,
        title: String,
        description: String,
        in context: NSManagedObjectContext
    ) throws -> Bookmark {
        guard let entity = try context.fetch(
            NSFetchRequest<BookmarkEntity>(entityName: "BookmarkEntity")
        ).first(where: { $0.id == bookmark.id }) else {
            throw BookmarkServiceError.bookmarkNotFound
        }

        try coreDataManager.updateBookmark(
            entity,
            title: title,
            description: description,
            in: context
        )
        return Bookmark(from: entity)
    }

    func deleteBookmark(_ bookmark: Bookmark, in context: NSManagedObjectContext) throws {
        guard let entity = try context.fetch(
            NSFetchRequest<BookmarkEntity>(entityName: "BookmarkEntity")
        ).first(where: { $0.id == bookmark.id }) else {
            throw BookmarkServiceError.bookmarkNotFound
        }
        try coreDataManager.softDelete(entity, in: context)
    }

    func fetchAllBookmarks(in context: NSManagedObjectContext) throws -> [Bookmark] {
        let entities = try coreDataManager.fetchAllBookmarks(in: context)
        return entities.map { Bookmark(from: $0) }
    }

    func searchBookmarks(query: String, in context: NSManagedObjectContext) throws -> [Bookmark] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return try fetchAllBookmarks(in: context)
        }
        let entities = try coreDataManager.searchBookmarks(query: query, in: context)
        return entities.map { Bookmark(from: $0) }
    }

    func sortBookmarks(_ bookmarks: [Bookmark], by sortOption: BookmarkSortOption) -> [Bookmark] {
        switch sortOption {
        case .dateCreatedNewest:
            return bookmarks.sorted { $0.dateCreated > $1.dateCreated }
        case .dateCreatedOldest:
            return bookmarks.sorted { $0.dateCreated < $1.dateCreated }
        case .alphabetical:
            return bookmarks.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .lastModified:
            return bookmarks.sorted { $0.lastModified > $1.lastModified }
        }
    }
}

enum BookmarkSortOption: String, CaseIterable {
    case dateCreatedNewest = "Newest First"
    case dateCreatedOldest = "Oldest First"
    case alphabetical = "Alphabetical"
    case lastModified = "Last Modified"
}

enum BookmarkServiceError: LocalizedError {
    case bookmarkNotFound
    case invalidURL
    case duplicateURL

    var errorDescription: String? {
        switch self {
        case .bookmarkNotFound:
            return "Bookmark not found"
        case .invalidURL:
            return "Invalid URL format"
        case .duplicateURL:
            return "URL already bookmarked"
        }
    }
}

import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "Bookmark")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data init failed: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func save(context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }

    func delete(_ bookmark: BookmarkEntity, in context: NSManagedObjectContext) throws {
        context.delete(bookmark)
        try save(context: context)
    }

    func softDelete(_ bookmark: BookmarkEntity, in context: NSManagedObjectContext) throws {
        bookmark.isArchived = true
        bookmark.lastModified = Date()
        try save(context: context)
    }

    func fetchAllBookmarks(in context: NSManagedObjectContext) throws -> [BookmarkEntity] {
        let request = BookmarkEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == false")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BookmarkEntity.dateCreated, ascending: false)]
        return try context.fetch(request)
    }

    func searchBookmarks(
        query: String,
        in context: NSManagedObjectContext
    ) throws -> [BookmarkEntity] {
        let request = BookmarkEntity.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "isArchived == false"),
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "title CONTAINS[cd] %@", query),
                NSPredicate(format: "descriptionText CONTAINS[cd] %@", query),
                NSPredicate(format: "url CONTAINS[cd] %@", query)
            ])
        ])
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BookmarkEntity.dateCreated, ascending: false)]
        return try context.fetch(request)
    }

    func fetchBookmark(byURL url: String, in context: NSManagedObjectContext) throws -> BookmarkEntity? {
        let request = BookmarkEntity.fetchRequest()
        request.predicate = NSPredicate(format: "url == %@", url)
        return try context.fetch(request).first
    }

    func updateBookmark(
        _ bookmark: BookmarkEntity,
        title: String,
        description: String,
        in context: NSManagedObjectContext
    ) throws {
        bookmark.title = title
        bookmark.descriptionText = description
        bookmark.lastModified = Date()
        try save(context: context)
    }
}

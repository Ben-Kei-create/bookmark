import Foundation
import CoreData

@objc(BookmarkEntity)
public class BookmarkEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var url: String
    @NSManaged public var title: String
    @NSManaged public var descriptionText: String
    @NSManaged public var dateCreated: Date
    @NSManaged public var lastModified: Date
    @NSManaged public var isArchived: Bool
    @NSManaged public var isFavorite: Bool
}

extension BookmarkEntity {
    static func fetchRequest() -> NSFetchRequest<BookmarkEntity> {
        NSFetchRequest<BookmarkEntity>(entityName: "BookmarkEntity")
    }

    static func makeNew(
        url: String,
        title: String,
        description: String,
        in context: NSManagedObjectContext
    ) -> BookmarkEntity {
        let entity = BookmarkEntity(context: context)
        entity.id = UUID()
        entity.url = url
        entity.title = title
        entity.descriptionText = description
        entity.dateCreated = Date()
        entity.lastModified = Date()
        entity.isArchived = false
        entity.isFavorite = false
        return entity
    }

    func toggleFavorite(in context: NSManagedObjectContext) throws {
        isFavorite.toggle()
        lastModified = Date()
        try context.save()
    }

    func softDelete(in context: NSManagedObjectContext) throws {
        isArchived = true
        lastModified = Date()
        try context.save()
    }

    func update(title: String, description: String, in context: NSManagedObjectContext) throws {
        self.title = title
        self.descriptionText = description
        self.lastModified = Date()
        try context.save()
    }
}

// Lightweight form data struct (used only for Add/Edit form state)
struct BookmarkFormData {
    var url: String = ""
    var title: String = ""
    var description: String = ""
}

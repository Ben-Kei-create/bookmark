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
}

extension BookmarkEntity {
    @NSFetchRequest(entity: BookmarkEntity.entity())
    static var allBookmarksFetchRequest: NSFetchRequest<BookmarkEntity>

    static func makeNewBookmark(
        url: String,
        title: String,
        description: String,
        in context: NSManagedObjectContext
    ) -> BookmarkEntity {
        let newBookmark = BookmarkEntity(context: context)
        newBookmark.id = UUID()
        newBookmark.url = url
        newBookmark.title = title
        newBookmark.descriptionText = description
        newBookmark.dateCreated = Date()
        newBookmark.lastModified = Date()
        newBookmark.isArchived = false
        return newBookmark
    }
}

struct Bookmark: Identifiable, Codable, Hashable {
    var id: UUID
    var url: String
    var title: String
    var description: String
    var dateCreated: Date
    var lastModified: Date
    var isArchived: Bool

    init(from entity: BookmarkEntity) {
        self.id = entity.id
        self.url = entity.url
        self.title = entity.title
        self.description = entity.descriptionText
        self.dateCreated = entity.dateCreated
        self.lastModified = entity.lastModified
        self.isArchived = entity.isArchived
    }

    init(
        id: UUID = UUID(),
        url: String,
        title: String,
        description: String = "",
        dateCreated: Date = Date(),
        lastModified: Date = Date(),
        isArchived: Bool = false
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.description = description
        self.dateCreated = dateCreated
        self.lastModified = lastModified
        self.isArchived = isArchived
    }
}

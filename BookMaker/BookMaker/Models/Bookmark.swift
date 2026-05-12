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
    @NSManaged public var folderName: String?
    @NSManaged public var tags: String?
    @NSManaged public var faviconURL: String?
    @NSManaged public var lastVisited: Date?
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
        entity.folderName = "Unsorted"
        entity.tags = ""
        entity.faviconURL = nil
        entity.lastVisited = nil
        return entity
    }

    // MARK: - Computed Properties

    var domain: String {
        guard let components = URLComponents(string: url),
              let host = components.host else {
            return url
        }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    var displayTitle: String {
        title.isEmpty ? domain : title
    }

    var tagList: [String] {
        guard let tags, !tags.isEmpty else { return [] }
        return tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    // MARK: - Mutations

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

    func updateTags(_ tagList: [String], in context: NSManagedObjectContext) throws {
        self.tags = tagList.joined(separator: ",")
        self.lastModified = Date()
        try context.save()
    }

    func recordVisit(in context: NSManagedObjectContext) throws {
        self.lastVisited = Date()
        try context.save()
    }
}


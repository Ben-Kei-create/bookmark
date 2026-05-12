import CoreData
import Combine
import Foundation

@MainActor
class BookmarkFormViewModel: ObservableObject {
    @Published var url = ""
    @Published var title = ""
    @Published var description = "" {
        didSet {
            if description.count > maxDescriptionLength {
                description = String(description.prefix(maxDescriptionLength))
            }
        }
    }
    @Published var urlError: String?
    @Published var isSaving = false
    @Published var saveError: String?
    @Published var tags: [String] = []
    @Published var tagInput = ""

    let editingEntity: BookmarkEntity?
    let maxTags = 10
    let maxDescriptionLength = 500

    var descriptionRemaining: Int { maxDescriptionLength - description.count }
    var isTagLimitReached: Bool { tags.count >= maxTags }

    init(editing entity: BookmarkEntity? = nil) {
        self.editingEntity = entity
        if let entity = entity {
            url = entity.url
            title = entity.title
            description = entity.descriptionText
            tags = entity.tagList
        }
    }

    func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !tags.contains(trimmed), tags.count < maxTags else {
            tagInput = ""
            return
        }
        tags.append(trimmed)
        tagInput = ""
    }

    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    var isFormValid: Bool {
        URLValidator.isValidURL(url) && urlError == nil
    }

    var titlePlaceholder: String {
        guard url.trimmingCharacters(in: .whitespaces).isEmpty == false,
              URLValidator.isValidURL(url) else { return AppStrings.title }
        let domain = URLValidator.extractDomain(from: URLValidator.normalizeURL(url))
        return domain.isEmpty ? AppStrings.title : domain
    }

    func validateURL(in context: NSManagedObjectContext? = nil) {
        let trimmed = url.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            urlError = nil
            return
        }
        guard URLValidator.isValidURL(trimmed) else {
            urlError = AppStrings.validURLRequired
            return
        }
        guard let context else {
            urlError = nil
            return
        }
        let normalized = URLValidator.normalizeURL(trimmed)
        let request = BookmarkEntity.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "url == %@", normalized),
            NSPredicate(format: "isArchived == false")
        ])
        request.fetchLimit = 1
        if let existing = try? context.fetch(request).first {
            if editingEntity == nil || existing.objectID != editingEntity!.objectID {
                urlError = AppStrings.duplicateURL
                return
            }
        }
        urlError = nil
    }

    func save(in context: NSManagedObjectContext) async throws {
        isSaving = true
        defer { isSaving = false }

        if let entity = editingEntity {
            try BookmarkService.update(
                entity,
                title: title.trimmingCharacters(in: .whitespaces),
                description: description,
                in: context
            )
        } else {
            try BookmarkService.create(
                url: url,
                title: title,
                description: description,
                in: context
            )
        }
    }

    func pasteFromClipboard() {
        if let pasted = ClipboardService.getFromClipboard(),
           URLValidator.isValidURL(pasted) {
            url = pasted
            if title.isEmpty {
                title = URLValidator.extractDomain(from: URLValidator.normalizeURL(pasted))
            }
        }
    }
}

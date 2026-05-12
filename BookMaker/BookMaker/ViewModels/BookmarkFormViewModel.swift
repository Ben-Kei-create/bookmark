import CoreData
import Foundation
import Combine

@MainActor
class BookmarkFormViewModel: ObservableObject {
    @Published var url = ""
    @Published var title = ""
    @Published var description = ""
    @Published var urlError: String?
    @Published var isSaving = false
    @Published var saveError: String?

    let editingEntity: BookmarkEntity?

    init(editing entity: BookmarkEntity? = nil) {
        self.editingEntity = entity
        if let entity = entity {
            url = entity.url
            title = entity.title
            description = entity.descriptionText
        }
    }

    var isFormValid: Bool {
        URLValidator.isValidURL(url)
    }

    // Suggested title from domain when title is empty
    var titlePlaceholder: String {
        guard url.trimmingCharacters(in: .whitespaces).isEmpty == false,
              URLValidator.isValidURL(url) else { return "Title" }
        let domain = URLValidator.extractDomain(from: URLValidator.normalizeURL(url))
        return domain.isEmpty ? "Title" : domain
    }

    func validateURL() {
        let trimmed = url.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            urlError = nil
        } else if !URLValidator.isValidURL(trimmed) {
            urlError = "Enter a valid URL (e.g. apple.com)"
        } else {
            urlError = nil
        }
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
            validateURL()
            if title.isEmpty {
                title = URLValidator.extractDomain(from: URLValidator.normalizeURL(pasted))
            }
        }
    }
}

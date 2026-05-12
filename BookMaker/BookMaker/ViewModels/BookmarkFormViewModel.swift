import CoreData
import Combine
import Foundation

@MainActor
class BookmarkFormViewModel: ObservableObject {
    @Published var url = ""
    @Published var title = ""
    @Published var description = ""
    @Published var urlError: String?
    @Published var isSaving = false
    @Published var saveError: String?
    @Published var tags: [String] = []
    @Published var tagInput = ""
    @Published var folderName = "Unsorted"

    let editingEntity: BookmarkEntity?

    init(editing entity: BookmarkEntity? = nil) {
        self.editingEntity = entity
        if let entity = entity {
            url = entity.url
            title = entity.title
            description = entity.descriptionText
            tags = entity.tagList
            folderName = entity.folderDisplayName
        }
    }

    func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else {
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
        URLValidator.isValidURL(url)
    }

    var titlePlaceholder: String {
        guard url.trimmingCharacters(in: .whitespaces).isEmpty == false,
              URLValidator.isValidURL(url) else { return AppStrings.title }
        let domain = URLValidator.extractDomain(from: URLValidator.normalizeURL(url))
        return domain.isEmpty ? AppStrings.title : domain
    }

    func validateURL() {
        let trimmed = url.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            urlError = nil
        } else if !URLValidator.isValidURL(trimmed) {
            urlError = AppStrings.validURLRequired
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

import CoreData
import Foundation
import Combine

class BookmarkFormViewModel: ObservableObject {
    @Published var url = ""
    @Published var title = ""
    @Published var description = ""
    @Published var urlError: String?
    @Published var isSaving = false
    @Published var formError: String?

    private let bookmarkService = BookmarkService.shared
    private let context: NSManagedObjectContext
    var editingBookmark: Bookmark?

    init(context: NSManagedObjectContext, editing bookmark: Bookmark? = nil) {
        self.context = context
        self.editingBookmark = bookmark

        if let bookmark = bookmark {
            self.url = bookmark.url
            self.title = bookmark.title
            self.description = bookmark.description
        }
    }

    var isFormValid: Bool {
        let urlValid = URLValidator.isValidURL(url)
        let titleValid = !title.trimmingCharacters(in: .whitespaces).isEmpty
        return urlValid && titleValid
    }

    func validateURL() {
        let trimmed = url.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            urlError = "URL is required"
        } else if !URLValidator.isValidURL(trimmed) {
            urlError = "Invalid URL format"
        } else {
            urlError = nil
        }
    }

    func save() async throws {
        isSaving = true
        defer { isSaving = false }

        validateURL()
        guard urlError == nil else {
            throw BookmarkServiceError.invalidURL
        }

        let normalizedURL = URLValidator.normalizeURL(url)
        let bookmarkTitle = title.trimmingCharacters(in: .whitespaces).isEmpty
            ? URLValidator.extractDomain(from: normalizedURL)
            : title

        if let editingBookmark = editingBookmark {
            _ = try bookmarkService.updateBookmark(
                editingBookmark,
                title: bookmarkTitle,
                description: description,
                in: context
            )
        } else {
            _ = try bookmarkService.createBookmark(
                url: normalizedURL,
                title: bookmarkTitle,
                description: description,
                in: context
            )
        }
    }

    func reset() {
        url = ""
        title = ""
        description = ""
        urlError = nil
        formError = nil
    }
}

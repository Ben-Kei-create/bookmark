import CoreData
import Foundation
import Combine

class BookmarkDetailViewModel: ObservableObject {
    @Published var bookmark: Bookmark
    @Published var isEditing = false
    @Published var errorMessage: String?

    private let bookmarkService = BookmarkService.shared
    private let context: NSManagedObjectContext

    init(bookmark: Bookmark, context: NSManagedObjectContext) {
        self.bookmark = bookmark
        self.context = context
    }

    func deleteBookmark() async throws {
        try bookmarkService.deleteBookmark(bookmark, in: context)
    }

    func openURL() {
        if let url = URL(string: bookmark.url) {
            UIApplication.shared.open(url)
        }
    }

    func copyURLToPasteboard() {
        ClipboardService.copyToClipboard(bookmark.url)
    }

    func shareBookmark() -> [Any] {
        return [bookmark.url]
    }
}

import CoreData
import Foundation
import Combine

class BookmarkListViewModel: NSObject, ObservableObject {
    @Published var bookmarks: [Bookmark] = []
    @Published var searchText = ""
    @Published var sortOption: BookmarkSortOption = .dateCreatedNewest
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let bookmarkService = BookmarkService.shared
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        fetchBookmarks()
    }

    func fetchBookmarks() {
        isLoading = true
        errorMessage = nil

        DispatchQueue.main.async {
            do {
                let searchQuery = self.searchText.trimmingCharacters(in: .whitespaces)
                let fetched = searchQuery.isEmpty
                    ? try self.bookmarkService.fetchAllBookmarks(in: self.context)
                    : try self.bookmarkService.searchBookmarks(query: searchQuery, in: self.context)

                self.bookmarks = self.bookmarkService.sortBookmarks(fetched, by: self.sortOption)
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func deleteBookmark(_ bookmark: Bookmark) {
        do {
            try bookmarkService.deleteBookmark(bookmark, in: context)
            bookmarks.removeAll { $0.id == bookmark.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateSortOption(_ option: BookmarkSortOption) {
        sortOption = option
        bookmarks = bookmarkService.sortBookmarks(bookmarks, by: option)
    }
}

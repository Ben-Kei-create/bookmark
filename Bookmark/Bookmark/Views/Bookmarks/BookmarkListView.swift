import SwiftUI

struct BookmarkListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Always fetch by creation date; in-memory sort handles other orders
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.dateCreated, order: .reverse)],
        predicate: NSPredicate(format: "isArchived == false")
    )
    private var allBookmarks: FetchedResults<BookmarkEntity>

    @State private var searchText = ""
    @State private var sortOption: BookmarkSortOption = .dateCreatedNewest
    @State private var showAddSheet = false

    private var displayBookmarks: [BookmarkEntity] {
        let filtered: [BookmarkEntity]
        if searchText.isEmpty {
            filtered = Array(allBookmarks)
        } else {
            let query = searchText.lowercased()
            filtered = allBookmarks.filter {
                $0.title.lowercased().contains(query)
                || $0.descriptionText.lowercased().contains(query)
                || $0.url.lowercased().contains(query)
            }
        }
        return sorted(filtered)
    }

    var body: some View {
        NavigationStack {
            Group {
                if allBookmarks.isEmpty {
                    EmptyStateView { showAddSheet = true }
                } else if displayBookmarks.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    bookmarkList
                }
            }
            .navigationTitle("Bookmarks")
            .searchable(text: $searchText, prompt: "Search bookmarks…")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    sortMenu
                }
            }
            .sheet(isPresented: $showAddSheet) {
                BookmarkFormView()
            }
        }
    }

    // MARK: - List

    private var bookmarkList: some View {
        List {
            ForEach(displayBookmarks) { bookmark in
                NavigationLink {
                    BookmarkDetailView(entity: bookmark)
                } label: {
                    BookmarkRow(entity: bookmark)
                }
                .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) { delete(bookmark) } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button { open(bookmark.url) } label: {
                        Label("Open", systemImage: "safari")
                    }
                    .tint(.blue)
                }
                .contextMenu {
                    Button { open(bookmark.url) } label: {
                        Label("Open in Safari", systemImage: "safari")
                    }
                    Button { ClipboardService.copyToClipboard(bookmark.url) } label: {
                        Label("Copy URL", systemImage: "doc.on.doc")
                    }
                    Divider()
                    Button(role: .destructive) { delete(bookmark) } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: displayBookmarks.map(\.objectID))
    }

    // MARK: - Sort Menu

    private var sortMenu: some View {
        Menu {
            ForEach(BookmarkSortOption.allCases) { option in
                Button {
                    withAnimation(.easeInOut) { sortOption = option }
                } label: {
                    HStack {
                        Label(option.rawValue, systemImage: option.icon)
                        if sortOption == option {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .fontWeight(.medium)
        }
    }

    // MARK: - Helpers

    private func sorted(_ bookmarks: [BookmarkEntity]) -> [BookmarkEntity] {
        switch sortOption {
        case .dateCreatedNewest: return bookmarks.sorted { $0.dateCreated > $1.dateCreated }
        case .dateCreatedOldest: return bookmarks.sorted { $0.dateCreated < $1.dateCreated }
        case .alphabetical: return bookmarks.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .lastModified: return bookmarks.sorted { $0.lastModified > $1.lastModified }
        }
    }

    private func delete(_ entity: BookmarkEntity) {
        withAnimation {
            try? BookmarkService.delete(entity, in: viewContext)
        }
    }

    private func open(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    BookmarkListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

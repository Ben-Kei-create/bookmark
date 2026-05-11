import SwiftUI

struct BookmarkListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: BookmarkListViewModel
    @State private var showAddSheet = false
    @State private var selectedBookmark: Bookmark?

    init() {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        _viewModel = StateObject(wrappedValue: BookmarkListViewModel(context: context))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.bookmarks.isEmpty {
                    EmptyStateView(action: { showAddSheet = true })
                } else {
                    bookmarksList
                }

                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Bookmarks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Sort By", selection: $viewModel.sortOption) {
                            ForEach(BookmarkSortOption.allCases, id: \.self) { option in
                                Label(option.rawValue, systemImage: "arrow.up.arrow.down")
                                    .tag(option)
                            }
                        }
                        .onChange(of: viewModel.sortOption) { _, newOption in
                            viewModel.updateSortOption(newOption)
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
            .searchable(
                text: $viewModel.searchText,
                prompt: "Search bookmarks"
            )
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.fetchBookmarks()
            }
            .sheet(isPresented: $showAddSheet) {
                BookmarkFormView(onSave: {
                    viewModel.fetchBookmarks()
                    showAddSheet = false
                })
                .environment(\.managedObjectContext, viewContext)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
    }

    private var bookmarksList: some View {
        List {
            ForEach(viewModel.bookmarks) { bookmark in
                NavigationLink(destination: BookmarkDetailView(bookmark: bookmark)) {
                    BookmarkRow(bookmark: bookmark)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        viewModel.deleteBookmark(bookmark)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    BookmarkListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

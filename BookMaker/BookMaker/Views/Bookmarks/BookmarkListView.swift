import SwiftUI
import CoreData

struct BookmarkListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.dateCreated, order: .reverse)],
        predicate: NSPredicate(format: "isArchived == false")
    )
    private var allBookmarks: FetchedResults<BookmarkEntity>

    @AppStorage("appLanguage") private var appLanguage = "en"
    @AppStorage("bookmarkLayout") private var bookmarkLayout = "list"
    @State private var searchText = ""
    @State private var sortOption: BookmarkSortOption = .dateCreatedNewest
    @State private var showAddSheet = false
    @State private var filterFavoritesOnly = false
    @State private var pendingDelete: BookmarkEntity?

    // MARK: - Computed

    private var displayBookmarks: [BookmarkEntity] {
        var result = Array(allBookmarks)

        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(q)
                || $0.descriptionText.lowercased().contains(q)
                || $0.url.lowercased().contains(q)
                || ($0.tags ?? "").lowercased().contains(q)
            }
        }

        if filterFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }

        return sorted(result)
    }

    private var groupedBookmarks: [(key: String, items: [BookmarkEntity])] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!

        var groups: [String: [BookmarkEntity]] = [:]
        for bm in displayBookmarks {
            let day = cal.startOfDay(for: bm.dateCreated)
            let key: String
            if day == today       { key = AppStrings.today }
            else if day == yesterday { key = AppStrings.yesterday }
            else                  { key = AppStrings.earlier }

            groups[key, default: []].append(bm)
        }

        return [AppStrings.today, AppStrings.yesterday, AppStrings.earlier]
            .compactMap { key in groups[key].map { (key: key, items: $0) } }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.paleBackground.ignoresSafeArea()

                if allBookmarks.isEmpty {
                    EmptyStateView { showAddSheet = true }
                } else {
                    VStack(spacing: 0) {
                        // Search + filter bar
                        VStack(spacing: AppTheme.Spacing.sm) {
                            SearchBarView(
                                text: $searchText,
                                placeholder: AppStrings.searchPlaceholder
                            )

                            filterChips
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(AppTheme.Colors.paleBackground)

                        if displayBookmarks.isEmpty {
                            Spacer()
                            ContentUnavailableView.search(text: searchText)
                            Spacer()
                        } else if bookmarkLayout == "grid" {
                            bookmarkGrid
                        } else {
                            bookmarkList
                        }
                    }
                }
            }
            .navigationTitle(AppStrings.bookmarks)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !allBookmarks.isEmpty {
                        Button {
                            showAddSheet = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.Colors.primaryBlue)
                                    .frame(width: 32, height: 32)
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    if !allBookmarks.isEmpty {
                        sortMenu
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                BookmarkFormView()
            }
            .alert(AppStrings.deleteBookmark, isPresented: .init(
                get: { pendingDelete != nil },
                set: { if !$0 { pendingDelete = nil } }
            )) {
                Button(AppStrings.delete, role: .destructive) {
                    if let bm = pendingDelete { deleteBookmark(bm) }
                }
                Button(AppStrings.cancel, role: .cancel) {}
            } message: {
                Text("\"\(pendingDelete?.displayTitle ?? "")\"\(AppStrings.willBeRemoved)")
            }
        }
    }

    private func deleteBookmark(_ entity: BookmarkEntity) {
        try? entity.softDelete(in: viewContext)
        pendingDelete = nil
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                FilterChip(
                    label: AppStrings.all,
                    isSelected: !filterFavoritesOnly
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        filterFavoritesOnly = false
                    }
                }

                FilterChip(
                    label: AppStrings.favorites,
                    isSelected: filterFavoritesOnly
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        filterFavoritesOnly = true
                    }
                }
            }
        }
    }

    // MARK: - Grid

    private var bookmarkGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                spacing: 16
            ) {
                ForEach(displayBookmarks) { bookmark in
                    NavigationLink {
                        BookmarkDetailView(entity: bookmark)
                    } label: {
                        BookmarkGridCell(entity: bookmark)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            pendingDelete = bookmark
                        } label: {
                            Label(AppStrings.delete, systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.top, AppTheme.Spacing.md)
            .padding(.bottom, 100)
        }
    }

    // MARK: - List

    private var bookmarkList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.lg, pinnedViews: .sectionHeaders) {
                ForEach(groupedBookmarks, id: \.key) { group in
                    Section {
                        ForEach(group.items) { bookmark in
                            NavigationLink {
                                BookmarkDetailView(entity: bookmark)
                            } label: {
                                BookmarkRow(entity: bookmark)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    pendingDelete = bookmark
                                } label: {
                                    Label(AppStrings.delete, systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        SectionHeaderLabel(title: group.key)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .background(AppTheme.Colors.paleBackground)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.top, AppTheme.Spacing.xs)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Sort Menu

    private var sortMenu: some View {
        Menu {
            ForEach(BookmarkSortOption.allCases) { option in
                Button {
                    withAnimation { sortOption = option }
                } label: {
                    HStack {
                        Text(option.displayName)
                        Spacer()
                        if sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.primaryBlue)
        }
    }

    // MARK: - Sort Helper

    private func sorted(_ bookmarks: [BookmarkEntity]) -> [BookmarkEntity] {
        switch sortOption {
        case .dateCreatedNewest: return bookmarks.sorted { $0.dateCreated > $1.dateCreated }
        case .dateCreatedOldest: return bookmarks.sorted { $0.dateCreated < $1.dateCreated }
        case .alphabetical:      return bookmarks.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .lastModified:      return bookmarks.sorted { $0.lastModified > $1.lastModified }
        }
    }
}

#Preview {
    BookmarkListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

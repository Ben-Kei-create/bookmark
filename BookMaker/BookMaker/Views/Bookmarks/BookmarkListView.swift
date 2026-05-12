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
    @State private var searchText = ""
    @State private var sortOption: BookmarkSortOption = .dateCreatedNewest
    @State private var showAddSheet = false
    @State private var filterFavoritesOnly = false

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
                || ($0.folderName ?? "").lowercased().contains(q)
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
                ToolbarItem(placement: .topBarLeading) {
                    sortMenu
                }
            }
            .sheet(isPresented: $showAddSheet) {
                BookmarkFormView()
            }
        }
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
                    Label(option.displayName, systemImage: option.icon)
                    if sortOption == option {
                        Image(systemName: "checkmark")
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

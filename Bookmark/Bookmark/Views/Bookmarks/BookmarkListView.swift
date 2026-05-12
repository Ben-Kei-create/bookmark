import SwiftUI
import CoreData

struct BookmarkListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.dateCreated, order: .reverse)],
        predicate: NSPredicate(format: "isArchived == false")
    )
    private var allBookmarks: FetchedResults<BookmarkEntity>

    @State private var searchText = ""
    @State private var sortOption: BookmarkSortOption = .dateCreatedNewest
    @State private var showAddSheet = false
    @State private var filterFavoritesOnly = false

    private var displayBookmarks: [BookmarkEntity] {
        var filtered: [BookmarkEntity]
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

        if filterFavoritesOnly {
            filtered = filtered.filter { $0.isFavorite }
        }

        return sorted(filtered)
    }

    private var groupedBookmarks: [(date: String, items: [BookmarkEntity])] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        var groups: [String: [BookmarkEntity]] = [:]

        for bookmark in displayBookmarks {
            let bookmarkDay = calendar.startOfDay(for: bookmark.dateCreated)
            let key: String
            if bookmarkDay == today {
                key = AppStrings.today
            } else if bookmarkDay == yesterday {
                key = AppStrings.yesterday
            } else {
                key = AppStrings.earlier
            }
            if groups[key] == nil { groups[key] = [] }
            groups[key]?.append(bookmark)
        }

        let order = [AppStrings.today, AppStrings.yesterday, AppStrings.earlier]
        return order.compactMap { key in
            guard let items = groups[key] else { return nil }
            return (date: key, items: items)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.paleBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    if !allBookmarks.isEmpty {
                        filterChips
                            .padding(.vertical, AppTheme.Spacing.md)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                    }

                    Group {
                        if allBookmarks.isEmpty {
                            EmptyStateView { showAddSheet = true }
                        } else if displayBookmarks.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                        } else {
                            bookmarkList
                        }
                    }
                }
            }
            .navigationTitle(AppStrings.bookmarks)
            .searchable(text: $searchText, prompt: AppStrings.searchPlaceholder)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.Colors.primaryBlue)
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

    private var filterChips: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ForEach([
                (label: AppStrings.all, isActive: !filterFavoritesOnly),
                (label: AppStrings.favorites, isActive: filterFavoritesOnly)
            ], id: \.label) { chip in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        filterFavoritesOnly = chip.label == AppStrings.favorites
                    }
                }) {
                    Text(chip.label)
                        .font(.callout)
                        .fontWeight(.medium)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .background(
                            chip.isActive
                                ? AppTheme.Colors.primaryBlue
                                : Color.white
                        )
                        .foregroundColor(chip.isActive ? .white : AppTheme.Colors.primaryBlue)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    chip.isActive
                                        ? Color.clear
                                        : AppTheme.Colors.lightBlue,
                                    lineWidth: 1
                                )
                        )
                        .clipShape(Capsule())
                }
            }

            Spacer()
        }
    }

    private var bookmarkList: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                ForEach(groupedBookmarks, id: \.date) { group in
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        Text(group.date)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .padding(.horizontal, AppTheme.Spacing.lg)

                        ForEach(group.items) { bookmark in
                            NavigationLink {
                                BookmarkDetailView(entity: bookmark)
                            } label: {
                                BookmarkRow(entity: bookmark)
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                        }
                    }
                }
            }
            .padding(.vertical, AppTheme.Spacing.lg)
        }
    }

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
                .foregroundColor(AppTheme.Colors.primaryBlue)
        }
    }

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

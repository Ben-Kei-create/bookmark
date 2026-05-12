import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedTab: AppTab = .bookmarks

    enum AppTab: CaseIterable {
        case bookmarks, settings

        var icon: String {
            switch self {
            case .bookmarks: return "bookmark.fill"
            case .settings: return "gear"
            }
        }

        var label: String {
            switch self {
            case .bookmarks: return AppStrings.bookmarks
            case .settings: return AppStrings.settings
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .bookmarks:
                    BookmarkListView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            floatingTabBar
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var floatingTabBar: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases, id: \.label) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.12),
                    radius: 24,
                    x: 0,
                    y: 8
                )
        )
        .padding(.horizontal, AppTheme.Spacing.xxl)
        .padding(.bottom, 28)
    }

    @ViewBuilder
    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = selectedTab == tab

        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: tab.icon)
                    .font(.system(size: 15, weight: .semibold))

                if isSelected {
                    Text(tab.label)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .transition(.opacity.combined(with: .scale(scale: 0.85)))
                }
            }
            .foregroundColor(
                isSelected ? AppTheme.Colors.primaryBlue : AppTheme.Colors.textSecondary
            )
            .padding(.horizontal, isSelected ? AppTheme.Spacing.lg : AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? AppTheme.Colors.lightBlue : Color.clear)
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedTab: AppTab = .bookmarks
    @AppStorage("colorScheme") private var colorScheme = "system"

    enum AppTab: CaseIterable {
        case bookmarks, settings

        var icon: String {
            switch self {
            case .bookmarks: "bookmark.fill"
            case .settings:  "gear"
            }
        }

        var label: String {
            switch self {
            case .bookmarks: AppStrings.bookmarks
            case .settings:  AppStrings.settings
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .bookmarks: BookmarkListView()
                case .settings:  SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            floatingTabBar
        }
        .ignoresSafeArea(edges: .bottom)
        .preferredColorScheme(preferredScheme)
    }

    private var preferredScheme: ColorScheme? {
        switch colorScheme {
        case "dark":  return .dark
        case "light": return .light
        default:      return nil
        }
    }

    // MARK: - Tab Bar

    private var floatingTabBar: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            ForEach(AppTab.allCases, id: \.label) { tab in
                tabButton(tab)
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(AppTheme.Colors.cardBackground)
                .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 8)
        )
        .padding(.horizontal, 48)
        .padding(.bottom, 28)
    }

    @ViewBuilder
    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = selectedTab == tab

        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.70)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 15, weight: .semibold))

                if isSelected {
                    Text(tab.label)
                        .font(AppTheme.Typography.footnote(weight: .semibold))
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.85, anchor: .leading)),
                            removal:   .opacity.combined(with: .scale(scale: 0.85, anchor: .leading))
                        ))
                }
            }
            .foregroundColor(isSelected ? AppTheme.Colors.primaryBlue : AppTheme.Colors.textSecondary)
            .padding(.vertical, 10)
            .padding(.horizontal, isSelected ? 18 : 14)
            .background(
                Capsule().fill(isSelected ? AppTheme.Colors.lightBlue : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.28, dampingFraction: 0.70), value: isSelected)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

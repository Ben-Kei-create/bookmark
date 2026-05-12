import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            BookmarkListView()
                .tabItem {
                    Label(AppStrings.bookmarks, systemImage: "bookmark.fill")
                }

            SettingsView()
                .tabItem {
                    Label(AppStrings.settings, systemImage: "gear")
                }
        }
        .tint(AppTheme.Colors.primaryBlue)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

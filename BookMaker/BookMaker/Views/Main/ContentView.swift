import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BookmarkListView()
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

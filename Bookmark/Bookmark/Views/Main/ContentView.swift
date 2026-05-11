import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        TabView {
            BookmarkListView()
                .environment(\.managedObjectContext, viewContext)
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

extension PersistenceController {
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        for i in 0..<10 {
            let newBookmark = BookmarkEntity(context: viewContext)
            newBookmark.id = UUID()
            newBookmark.url = "https://example\(i).com"
            newBookmark.title = "Example Bookmark \(i)"
            newBookmark.descriptionText = "This is a preview bookmark for testing purposes"
            newBookmark.dateCreated = Date()
            newBookmark.lastModified = Date()
            newBookmark.isArchived = false
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return result
    }()
}

import SwiftUI
import CoreData

@main
struct BookmarkApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Bookmark")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.persistentStoreDescriptions.forEach { desc in
            desc.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
            desc.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data load failed: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Preview helper
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        let samples: [(String, String, String)] = [
            ("https://swift.org", "Swift.org", "The official Swift language website"),
            ("https://developer.apple.com", "Apple Developer", "Resources for building apps on Apple platforms"),
            ("https://www.hackingwithswift.com", "Hacking with Swift", "Free Swift tutorials and projects"),
            ("https://swiftui-lab.com", "SwiftUI Lab", "Deep dives into SwiftUI functionality"),
            ("https://pointfree.co", "Point-Free", "Functional programming in Swift"),
        ]

        for (url, title, desc) in samples {
            _ = BookmarkEntity.makeNew(url: url, title: title, description: desc, in: context)
        }

        try? context.save()
        return controller
    }()
}

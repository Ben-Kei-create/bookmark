import CoreData

// Minimal Core Data stack for the Share Extension
// Uses the same App Group container as the main app
class SharedPersistence {
    static let shared: SharedPersistence? = SharedPersistence()

    let container: NSPersistentContainer

    init?() {
        guard let groupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.fumiakiMogi777.BookMaker") else {
            print("❌ SharedPersistence: App Group コンテナ取得失敗")
            return nil
        }
        print("✅ SharedPersistence: App Group コンテナ取得成功: \(groupURL.path)")

        let storeURL = groupURL.appendingPathComponent("Bookmark.sqlite")
        print("✅ SharedPersistence: ストア URL: \(storeURL.path)")

        let description = NSPersistentStoreDescription(url: storeURL)
        description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        description.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)

        // Load the model from the main app bundle by name
        guard let modelURL = Bundle.main.url(forResource: "Bookmark", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("❌ SharedPersistence: Core Data Model (Bookmark.momd) 読み込み失敗")
            return nil
        }
        print("✅ SharedPersistence: Core Data Model 読み込み成功")

        container = NSPersistentContainer(name: "Bookmark", managedObjectModel: model)
        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
            if let error = error {
                print("❌ SharedPersistence: ストア読み込み失敗: \(error.localizedDescription)")
            } else {
                print("✅ SharedPersistence: ストア読み込み成功")
            }
        }
        if loadError != nil { return nil }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

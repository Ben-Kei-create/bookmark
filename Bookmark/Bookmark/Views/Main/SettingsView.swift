import SwiftUI

struct SettingsView: View {
    @State private var selectedSort = BookmarkSortOption.dateCreatedNewest
    @AppStorage("bookmarkSortOption") var sortOptionKey: String = BookmarkSortOption.dateCreatedNewest.rawValue

    var body: some View {
        NavigationStack {
            Form {
                Section("Sort Options") {
                    Picker("Default Sort", selection: $sortOptionKey) {
                        ForEach(BookmarkSortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option.rawValue)
                        }
                    }
                    .onChange(of: sortOptionKey) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "bookmarkSortOption")
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }

                Section("Support") {
                    if let email = URL(string: "mailto:support@example.com") {
                        Link(destination: email) {
                            Text("Contact Support")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}

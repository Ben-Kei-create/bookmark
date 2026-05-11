import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultSortOption") private var defaultSortKey = BookmarkSortOption.dateCreatedNewest.rawValue

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Default Sort", selection: $defaultSortKey) {
                        ForEach(BookmarkSortOption.allCases) { option in
                            Label(option.rawValue, systemImage: option.icon).tag(option.rawValue)
                        }
                    }
                } header: {
                    Text("Preferences")
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(.secondary)
                    }

                    if let url = URL(string: "mailto:support@example.com") {
                        Link(destination: url) {
                            Label("Contact Support", systemImage: "envelope")
                        }
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}

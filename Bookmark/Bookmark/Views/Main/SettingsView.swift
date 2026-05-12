import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultSortOption") private var defaultSortKey = BookmarkSortOption.dateCreatedNewest.rawValue
    @AppStorage("appLanguage") private var appLanguage = "en"

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.paleBackground
                    .ignoresSafeArea()

                Form {
                    Section {
                        Picker(AppStrings.language, selection: $appLanguage) {
                            Text(AppStrings.english).tag("en")
                            Text(AppStrings.japanese).tag("ja")
                        }
                        .pickerStyle(.segmented)
                    } header: {
                        Text(AppStrings.preferences)
                    }

                    Section {
                        Picker(AppStrings.defaultSort, selection: $defaultSortKey) {
                            ForEach(BookmarkSortOption.allCases) { option in
                                Label(option.rawValue, systemImage: option.icon).tag(option.rawValue)
                            }
                        }
                    }

                    Section {
                        HStack {
                            Text(AppStrings.version)
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }

                        if let url = URL(string: "mailto:support@example.com") {
                            Link(destination: url) {
                                Label(AppStrings.contactSupport, systemImage: "envelope")
                            }
                        }
                    } header: {
                        Text(AppStrings.about)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(AppStrings.settings)
        }
    }
}

#Preview {
    SettingsView()
}

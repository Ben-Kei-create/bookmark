import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.dateCreated, order: .reverse)],
        predicate: NSPredicate(format: "isArchived == false")
    )
    private var allBookmarks: FetchedResults<BookmarkEntity>

    @AppStorage("appLanguage") private var appLanguage = "en"
    @AppStorage("bookmarkLayout") private var bookmarkLayout = "list"
    @AppStorage("colorScheme") private var colorScheme = "system"
    @State private var showClearAlert = false
    @State private var openLinksIn = "Safari"
    @State private var showExportSheet = false
    @State private var exportFileURL: URL?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.paleBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        appHeader
                        generalSection
                        appearanceSection
                        dataSection
                        aboutSection
                        Spacer().frame(height: AppTheme.Spacing.xxxl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.md)
                }
            }
            .navigationTitle(AppStrings.settings)
            .navigationBarTitleDisplayMode(.large)
            .alert(AppStrings.clearAllConfirmTitle, isPresented: $showClearAlert) {
                Button(AppStrings.clearAllBookmarks, role: .destructive) { }
                Button(AppStrings.cancel, role: .cancel) { }
            } message: {
                Text(AppStrings.clearAllConfirmMessage)
            }
            .sheet(isPresented: $showExportSheet) {
                if let url = exportFileURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    // MARK: - Export

    private func exportBookmarks() {
        struct ExportItem: Codable {
            let url: String
            let title: String
            let description: String
            let folder: String
            let tags: [String]
            let isFavorite: Bool
            let dateCreated: String
        }

        let formatter = ISO8601DateFormatter()
        let items = allBookmarks.map { bm in
            ExportItem(
                url: bm.url,
                title: bm.title,
                description: bm.descriptionText,
                folder: bm.folderName ?? "Unsorted",
                tags: bm.tagList,
                isFavorite: bm.isFavorite,
                dateCreated: formatter.string(from: bm.dateCreated)
            )
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(items) else { return }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("bookmarks_export.json")
        try? data.write(to: tempURL)
        exportFileURL = tempURL
        showExportSheet = true
    }

    // MARK: - App Header Card

    private var appHeader: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                    .fill(AppTheme.Gradients.primary)
                    .frame(width: 58, height: 58)
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("BookMaker")
                    .font(AppTheme.Typography.title3(weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Text(AppStrings.appSubtitle)
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            Spacer()
        }
        .appCardStyle(padding: AppTheme.Spacing.md)
    }

    // MARK: - General

    private var generalSection: some View {
        SettingsGroupCard(title: AppStrings.generalSection) {
            VStack(spacing: 0) {
                settingsPickerRow(
                    icon: "square.grid.2x2", iconColor: Color.purple,
                    label: AppStrings.displayStyle,
                    selection: $bookmarkLayout,
                    options: [(AppStrings.listStyle, "list"), (AppStrings.gridStyle, "grid")]
                )
                SettingsDivider()
                settingsPickerRow(
                    icon: "globe", iconColor: Color.teal,
                    label: AppStrings.openLinksIn,
                    selection: $openLinksIn,
                    options: [("Safari", "Safari"), ("In-App Browser", "In-App Browser")]
                )
            }
        }
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        SettingsGroupCard(title: AppStrings.appearanceSection) {
            VStack(spacing: AppTheme.Spacing.md) {
                // Dark mode picker
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    HStack {
                        SettingsIcon(name: "moon.stars.fill", color: Color.indigo)
                        Text(AppStrings.appearanceModeLabel)
                            .font(AppTheme.Typography.subheadline(weight: .medium))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        Spacer()
                    }

                    HStack(spacing: AppTheme.Spacing.sm) {
                        AppearanceModeButton(
                            label: AppStrings.systemMode,
                            value: "system", selection: $colorScheme
                        )
                        AppearanceModeButton(
                            label: AppStrings.lightMode,
                            value: "light", selection: $colorScheme
                        )
                        AppearanceModeButton(
                            label: AppStrings.darkModeOption,
                            value: "dark", selection: $colorScheme
                        )
                    }
                }
                .padding(AppTheme.Spacing.md)

                Divider()
                    .padding(.leading, AppTheme.Spacing.md)

                // Language picker
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    HStack {
                        SettingsIcon(name: "globe", color: AppTheme.Colors.deepBlue)
                        Text(AppStrings.languageLabel)
                            .font(AppTheme.Typography.subheadline(weight: .medium))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        Spacer()
                    }

                    Picker(AppStrings.languageLabel, selection: $appLanguage) {
                        Text(AppStrings.english).tag("en")
                        Text(AppStrings.japanese).tag("ja")
                    }
                    .pickerStyle(.segmented)
                }
                .padding(AppTheme.Spacing.md)
                .padding(.top, 0)
            }
        }
    }

    // MARK: - Data

    private var dataSection: some View {
        SettingsGroupCard(title: AppStrings.dataSection) {
            VStack(spacing: 0) {
                settingsActionRow(icon: "square.and.arrow.up", iconColor: Color.indigo,
                                  label: AppStrings.exportBookmarks) {
                    exportBookmarks()
                }
                SettingsDivider()
                settingsActionRow(icon: "trash.fill", iconColor: Color.red,
                                  label: AppStrings.clearAllBookmarks, isDestructive: true) {
                    showClearAlert = true
                }
            }
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        SettingsGroupCard(title: AppStrings.about) {
            VStack(spacing: 0) {
                HStack {
                    SettingsIcon(name: "app.badge.fill", color: AppTheme.Colors.primaryBlue)
                    Text(AppStrings.version)
                        .font(AppTheme.Typography.subheadline(weight: .medium))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .font(AppTheme.Typography.subheadline())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .padding(AppTheme.Spacing.md)

                SettingsDivider()

                if let mailto = URL(string: "mailto:support@example.com") {
                    Link(destination: mailto) {
                        HStack {
                            SettingsIcon(name: "envelope.fill", color: Color.orange)
                            Text(AppStrings.contactSupport)
                                .font(AppTheme.Typography.subheadline(weight: .medium))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        .padding(AppTheme.Spacing.md)
                    }
                }

                SettingsDivider()

                settingsActionRow(icon: "hand.raised.fill", iconColor: Color.purple,
                                  label: AppStrings.privacyPolicy) { }
            }
        }
    }

    // MARK: - Reusable Row Builders

    private func settingsActionRow(icon: String, iconColor: Color, label: String,
                                   isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                SettingsIcon(name: icon, color: iconColor)
                Text(label)
                    .font(AppTheme.Typography.subheadline(weight: .medium))
                    .foregroundColor(isDestructive ? .red : AppTheme.Colors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(AppTheme.Spacing.md)
        }
        .buttonStyle(.plain)
    }

    private func settingsPickerRow(icon: String, iconColor: Color, label: String,
                                   selection: Binding<String>, options: [(String, String)]) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            SettingsIcon(name: icon, color: iconColor)
            Picker(label, selection: selection) {
                ForEach(options, id: \.1) { opt in
                    Text(opt.0).tag(opt.1)
                }
            }
            .tint(AppTheme.Colors.primaryBlue)
            Spacer()
        }
        .padding(AppTheme.Spacing.md)
    }
}

// MARK: - AppearanceModeButton

struct AppearanceModeButton: View {
    let label: String
    let value: String
    @Binding var selection: String

    private var isSelected: Bool { selection == value }

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selection = value
            }
        } label: {
            Text(label)
                .font(AppTheme.Typography.subheadline(weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? AppTheme.Colors.primaryBlue : AppTheme.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous)
                        .fill(isSelected ? AppTheme.Colors.lightBlue : AppTheme.Colors.paleBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous)
                        .stroke(
                            isSelected ? AppTheme.Colors.primaryBlue.opacity(0.4) : AppTheme.Colors.divider,
                            lineWidth: 1.5
                        )
                )
        }
        .buttonStyle(.plain)
    }

}

// MARK: - Local Helper Components (Settings-scoped)

struct SettingsGroupCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            SectionHeaderLabel(title: title)
                .padding(.horizontal, AppTheme.Spacing.xs)

            content
                .background(AppTheme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

struct SettingsIcon: View {
    let name: String
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(color)
                .frame(width: 30, height: 30)
            Image(systemName: name)
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
    }
}

struct SettingsDivider: View {
    var body: some View {
        Divider().padding(.leading, 50)
    }
}

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

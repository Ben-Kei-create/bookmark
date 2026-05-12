import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultSortOption") private var defaultSortKey = BookmarkSortOption.dateCreatedNewest.rawValue
    @AppStorage("appLanguage") private var appLanguage = "en"
    @State private var showClearAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.paleBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        profileHeader

                        generalSection
                        appearanceSection
                        dataSection
                        aboutSection

                        Spacer().frame(height: AppTheme.Spacing.xxl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.md)
                }
            }
            .navigationTitle(AppStrings.settings)
            .navigationBarTitleDisplayMode(.large)
            .alert("Clear All Bookmarks?", isPresented: $showClearAlert) {
                Button("Clear All", role: .destructive) { }
                Button(AppStrings.cancel, role: .cancel) { }
            } message: {
                Text("This will permanently delete all your bookmarks. This action cannot be undone.")
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [AppTheme.Colors.primaryBlue, AppTheme.Colors.deepBlue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))

                Image(systemName: "bookmark.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Bookmark")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("Your personal bookmark manager")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(Color.white)
        .cornerRadius(AppTheme.Radius.lg)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - General Section

    private var generalSection: some View {
        SettingsSection(title: "General", icon: "slider.horizontal.3") {
            VStack(spacing: 0) {
                SettingsPickerRow(
                    icon: "arrow.up.arrow.down",
                    iconColor: AppTheme.Colors.primaryBlue,
                    label: AppStrings.defaultSort,
                    selection: $defaultSortKey,
                    options: BookmarkSortOption.allCases.map { ($0.rawValue, $0.rawValue) }
                )

                SettingsDivider()

                SettingsPickerRow(
                    icon: "globe",
                    iconColor: Color.teal,
                    label: "Open Links In",
                    selection: .constant("Safari"),
                    options: [("Safari", "Safari"), ("In-App Browser", "In-App Browser")]
                )
            }
        }
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        SettingsSection(title: "Appearance", icon: "paintbrush.fill") {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    HStack {
                        SettingsIconBox(systemName: "globe", color: AppTheme.Colors.deepBlue)
                        Text(AppStrings.language)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.md)

                    Picker(AppStrings.language, selection: $appLanguage) {
                        Text(AppStrings.english).tag("en")
                        Text(AppStrings.japanese).tag("ja")
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.bottom, AppTheme.Spacing.md)
                }
            }
        }
    }

    // MARK: - Data Section

    private var dataSection: some View {
        SettingsSection(title: "Data", icon: "cylinder.split.1x2.fill") {
            VStack(spacing: 0) {
                SettingsActionRow(
                    icon: "square.and.arrow.up",
                    iconColor: Color.indigo,
                    label: "Export Bookmarks"
                ) { }

                SettingsDivider()

                SettingsActionRow(
                    icon: "square.and.arrow.down",
                    iconColor: Color.teal,
                    label: "Import Bookmarks"
                ) { }

                SettingsDivider()

                SettingsActionRow(
                    icon: "trash.fill",
                    iconColor: .red,
                    label: "Clear All Bookmarks",
                    isDestructive: true
                ) { showClearAlert = true }
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        SettingsSection(title: AppStrings.about, icon: "info.circle.fill") {
            VStack(spacing: 0) {
                HStack {
                    SettingsIconBox(systemName: "app.badge", color: AppTheme.Colors.primaryBlue)
                    Text(AppStrings.version)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .padding(AppTheme.Spacing.md)

                SettingsDivider()

                if let url = URL(string: "mailto:support@example.com") {
                    Link(destination: url) {
                        HStack {
                            SettingsIconBox(systemName: "envelope.fill", color: Color.orange)
                            Text(AppStrings.contactSupport)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        .padding(AppTheme.Spacing.md)
                    }
                }

                SettingsDivider()

                SettingsActionRow(
                    icon: "hand.raised.fill",
                    iconColor: Color.purple,
                    label: "Privacy Policy"
                ) { }
            }
        }
    }
}

// MARK: - Reusable Settings Components

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Label(title, systemImage: icon)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .textCase(.uppercase)
                .padding(.horizontal, AppTheme.Spacing.xs)

            content
                .background(Color.white)
                .cornerRadius(AppTheme.Radius.md)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

struct SettingsIconBox: View {
    let systemName: String
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(color)
                .frame(width: 30, height: 30)
            Image(systemName: systemName)
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
    }
}

struct SettingsDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 54)
    }
}

struct SettingsActionRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                SettingsIconBox(systemName: icon, color: iconColor)
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isDestructive ? .red : AppTheme.Colors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(AppTheme.Spacing.md)
        }
        .buttonStyle(.plain)
    }
}

struct SettingsPickerRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    @Binding var selection: String
    let options: [(label: String, value: String)]

    var body: some View {
        HStack {
            SettingsIconBox(systemName: icon, color: iconColor)
            Picker(label, selection: $selection) {
                ForEach(options, id: \.value) { option in
                    Text(option.label).tag(option.value)
                }
            }
            .tint(AppTheme.Colors.primaryBlue)
        }
        .padding(AppTheme.Spacing.md)
    }
}

#Preview {
    SettingsView()
}

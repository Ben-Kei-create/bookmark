import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultSortOption") private var defaultSortKey = BookmarkSortOption.dateCreatedNewest.rawValue
    @AppStorage("appLanguage") private var appLanguage = "en"
    @State private var showClearAlert = false
    @State private var openLinksIn = "Safari"

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
        }
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
                Text("Bookmark")
                    .font(AppTheme.Typography.title3(weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Text("Your private bookmark manager")
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
                    icon: "arrow.up.arrow.down", iconColor: AppTheme.Colors.primaryBlue,
                    label: AppStrings.defaultSort,
                    selection: $defaultSortKey,
                    options: BookmarkSortOption.allCases.map { ($0.displayName, $0.rawValue) }
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
        }
    }

    // MARK: - Data

    private var dataSection: some View {
        SettingsGroupCard(title: AppStrings.dataSection) {
            VStack(spacing: 0) {
                settingsActionRow(icon: "square.and.arrow.up", iconColor: Color.indigo,
                                  label: AppStrings.exportBookmarks) { }
                SettingsDivider()
                settingsActionRow(icon: "square.and.arrow.down", iconColor: Color.teal,
                                  label: AppStrings.importBookmarks) { }
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
                // Version row
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
                .background(Color.white)
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

#Preview {
    SettingsView()
}

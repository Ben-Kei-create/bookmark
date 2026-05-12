import SwiftUI
import CoreData

struct BookmarkDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var entity: BookmarkEntity

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var showShareSheet = false
    @State private var urlCopied = false

    var body: some View {
        ZStack {
            AppTheme.Colors.paleBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    headerSection

                    if !entity.descriptionText.isEmpty {
                        descriptionSection
                    }

                    actionButtons

                    metaSection
                }
                .padding(AppTheme.Spacing.lg)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showEditSheet = true } label: {
                        Label(AppStrings.edit, systemImage: "pencil")
                    }
                    Button { showShareSheet = true } label: {
                        Label(AppStrings.share, systemImage: "square.and.arrow.up")
                    }
                    Divider()
                    Button(role: .destructive) { showDeleteAlert = true } label: {
                        Label(AppStrings.delete, systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(AppTheme.Colors.primaryBlue)
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            BookmarkFormView(editing: entity)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [entity.url])
                .presentationDetents([.medium, .large])
        }
        .alert(AppStrings.deleteBookmark, isPresented: $showDeleteAlert) {
            Button(AppStrings.delete, role: .destructive) { deleteAndDismiss() }
            Button(AppStrings.cancel, role: .cancel) {}
        } message: {
            Text("\"\(entity.title)\"\(AppStrings.willBeRemoved)")
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(entity.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.Colors.textPrimary)

            Button { openInSafari() } label: {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "link")
                        .font(.caption)
                    Text(URLValidator.extractDomain(from: entity.url))
                        .font(.subheadline)
                    Image(systemName: "arrow.up.right")
                        .font(.caption2)
                }
                .foregroundColor(AppTheme.Colors.primaryBlue)
            }
            .buttonStyle(.plain)
        }
        .appCardStyle()
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Label(AppStrings.notes, systemImage: "text.alignleft")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.Colors.textSecondary)

            Text(entity.descriptionText)
                .font(.body)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .appCardStyle()
    }

    private var actionButtons: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Button(action: openInSafari) {
                HStack {
                    Image(systemName: "safari.fill")
                    Text(AppStrings.openInSafari)
                    Spacer()
                }
                .frame(height: 48)
                .padding(.horizontal, AppTheme.Spacing.md)
            }
            .appPrimaryButtonStyle()

            HStack(spacing: AppTheme.Spacing.md) {
                Button(action: copyURL) {
                    HStack {
                        Image(systemName: urlCopied ? "checkmark" : "doc.on.doc")
                        Text(urlCopied ? AppStrings.copied : AppStrings.copyURL)
                        Spacer()
                    }
                    .frame(height: 48)
                    .padding(.horizontal, AppTheme.Spacing.md)
                }
                .appSecondaryButtonStyle()
                .animation(.easeInOut(duration: 0.15), value: urlCopied)

                Button { showShareSheet = true } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text(AppStrings.share)
                        Spacer()
                    }
                    .frame(height: 48)
                    .padding(.horizontal, AppTheme.Spacing.md)
                }
                .appSecondaryButtonStyle()
            }
        }
    }

    private var metaSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                Text(AppStrings.added)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                Spacer()
                Text(entity.dateCreated.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            if entity.lastModified.timeIntervalSince(entity.dateCreated) > 5 {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    Text(AppStrings.edited)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    Spacer()
                    Text(entity.lastModified.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
        .appCardStyle()
    }

    private func openInSafari() {
        guard let url = URL(string: entity.url) else { return }
        UIApplication.shared.open(url)
    }

    private func copyURL() {
        ClipboardService.copyToClipboard(entity.url)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        urlCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { urlCopied = false }
    }

    private func deleteAndDismiss() {
        try? BookmarkService.delete(entity, in: viewContext)
        dismiss()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        let context = PersistenceController.preview.container.viewContext
        let entity = (try! context.fetch(BookmarkEntity.fetchRequest())).first!
        BookmarkDetailView(entity: entity)
            .environment(\.managedObjectContext, context)
    }
}

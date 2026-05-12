import SwiftUI
import CoreData
import SafariServices

struct BookmarkDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var entity: BookmarkEntity
    @AppStorage("appLanguage") private var appLanguage = "en"
    @AppStorage("openLinksIn") private var openLinksIn = "Safari"

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var showShareSheet = false
    @State private var showInAppBrowser = false
    @State private var urlCopied = false

    var body: some View {
        ZStack {
            AppTheme.Colors.paleBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    heroCard
                    actionRow
                    if !entity.descriptionText.isEmpty { notesCard }
                    if !entity.tagList.isEmpty { tagsCard }
                    metaCard
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.md)
                .padding(.bottom, 100)
            }
        }
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
            ShareSheet(items: [entity.url])
                .presentationDetents([.medium, .large])
        }
        .fullScreenCover(isPresented: $showInAppBrowser) {
            if let url = URL(string: entity.url) {
                SafariView(url: url).ignoresSafeArea()
            }
        }
        .alert(AppStrings.deleteBookmark, isPresented: $showDeleteAlert) {
            Button(AppStrings.delete, role: .destructive) { deleteAndDismiss() }
            Button(AppStrings.cancel, role: .cancel) {}
        } message: {
            Text("\"\(entity.title)\"\(AppStrings.willBeRemoved)")
        }
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.md) {
                DomainIconView(domain: entity.domain, size: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text(entity.displayTitle)
                        .font(AppTheme.Typography.title3(weight: .bold))
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Button { openInSafari() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "link")
                                .font(.system(size: 11))
                            Text(entity.domain)
                                .font(AppTheme.Typography.footnote())
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(AppTheme.Colors.primaryBlue)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }

        }
        .appCardStyle(padding: AppTheme.Spacing.lg)
    }

    // MARK: - Action Row

    private var actionRow: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            // Open in Safari
            Button(action: openInSafari) {
                VStack(spacing: 4) {
                    Image(systemName: "safari.fill")
                        .font(.system(size: 20))
                    Text("Open")
                        .font(AppTheme.Typography.caption(weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .foregroundColor(.white)
                .background(AppTheme.Gradients.primary)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
            }
            .buttonStyle(.plain)

            // Copy URL
            Button(action: copyURL) {
                VStack(spacing: 4) {
                    Image(systemName: urlCopied ? "checkmark" : "doc.on.doc.fill")
                        .font(.system(size: 20))
                    Text(urlCopied ? AppStrings.copied : "Copy")
                        .font(AppTheme.Typography.caption(weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .foregroundColor(AppTheme.Colors.primaryBlue)
                .background(AppTheme.Colors.lightBlue)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
            }
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.15), value: urlCopied)

            // Share
            Button { showShareSheet = true } label: {
                VStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up.fill")
                        .font(.system(size: 20))
                    Text(AppStrings.share)
                        .font(AppTheme.Typography.caption(weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .foregroundColor(AppTheme.Colors.primaryBlue)
                .background(AppTheme.Colors.lightBlue)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Notes Card

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Label("Notes", systemImage: "note.text")
                .font(AppTheme.Typography.caption(weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)

            Text(entity.descriptionText)
                .font(AppTheme.Typography.subheadline())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .appCardStyle()
    }

    // MARK: - Tags Card

    private var tagsCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Label("Tags", systemImage: "tag.fill")
                .font(AppTheme.Typography.caption(weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)

            FlowLayout(spacing: AppTheme.Spacing.sm) {
                ForEach(entity.tagList, id: \.self) { tag in
                    TagChip(tag: tag)
                }
            }
        }
        .appCardStyle()
    }

    // MARK: - Meta Card

    private var metaCard: some View {
        VStack(spacing: 0) {
            metaRow(icon: "calendar", label: AppStrings.added,
                    value: entity.dateCreated.formatted(date: .abbreviated, time: .shortened))

            if entity.lastModified.timeIntervalSince(entity.dateCreated) > 5 {
                Divider().padding(.leading, 36)
                metaRow(icon: "pencil", label: AppStrings.edited,
                        value: entity.lastModified.formatted(date: .abbreviated, time: .shortened))
            }

            if let lastVisited = entity.lastVisited {
                Divider().padding(.leading, 36)
                metaRow(icon: "eye", label: "Last visited",
                        value: lastVisited.formatted(date: .abbreviated, time: .shortened))
            }
        }
        .appCardStyle()
    }

    private func metaRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.Colors.primaryBlue)
                .frame(width: 20)

            Text(label)
                .font(AppTheme.Typography.footnote(weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)

            Spacer()

            Text(value)
                .font(AppTheme.Typography.footnote())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding(.vertical, AppTheme.Spacing.sm)
    }

    // MARK: - Actions

    private func openInSafari() {
        guard URL(string: entity.url) != nil else { return }
        try? entity.recordVisit(in: viewContext)
        if openLinksIn == "In-App Browser" {
            showInAppBrowser = true
        } else {
            UIApplication.shared.open(URL(string: entity.url)!)
        }
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


#Preview {
    NavigationStack {
        let ctx = PersistenceController.preview.container.viewContext
        let entity = (try! ctx.fetch(BookmarkEntity.fetchRequest())).first!
        BookmarkDetailView(entity: entity)
            .environment(\.managedObjectContext, ctx)
    }
}

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
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                    .padding(.top, 4)

                if !entity.descriptionText.isEmpty {
                    descriptionSection
                }

                actionButtons
                    .padding(.top, 4)

                metaSection
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showEditSheet = true } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button { showShareSheet = true } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Divider()
                    Button(role: .destructive) { showDeleteAlert = true } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
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
        .alert("Delete Bookmark?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) { deleteAndDismiss() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("\"\(entity.title)\" will be removed.")
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entity.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Button { openInSafari() } label: {
                HStack(spacing: 4) {
                    Text(URLValidator.extractDomain(from: entity.url))
                        .font(.subheadline)
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                }
                .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Notes", systemImage: "text.alignleft")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(entity.descriptionText)
                .font(.body)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button(action: openInSafari) {
                Label("Open in Safari", systemImage: "safari.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(PrimaryButtonStyle())

            HStack(spacing: 10) {
                Button(action: copyURL) {
                    Label(urlCopied ? "Copied!" : "Copy URL",
                          systemImage: urlCopied ? "checkmark" : "doc.on.doc")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(SecondaryButtonStyle())
                .animation(.easeInOut(duration: 0.15), value: urlCopied)

                Button { showShareSheet = true } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
    }

    private var metaSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Added \(entity.dateCreated.formatted(date: .long, time: .shortened))")
                .font(.caption)
                .foregroundColor(.secondary)

            if entity.lastModified.timeIntervalSince(entity.dateCreated) > 5 {
                Text("Edited \(entity.lastModified.formatted(date: .long, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    // MARK: - Actions

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

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .background(Color.accentColor.opacity(configuration.isPressed ? 0.8 : 1))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color(.secondarySystemGroupedBackground).opacity(configuration.isPressed ? 0.7 : 1))
            .foregroundColor(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

// MARK: - Share Sheet

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

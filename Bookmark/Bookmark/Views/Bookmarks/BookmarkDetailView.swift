import SwiftUI

struct BookmarkDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: BookmarkDetailViewModel
    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showCopiedMessage = false
    @State private var isDeleting = false

    init(bookmark: Bookmark) {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        _viewModel = StateObject(
            wrappedValue: BookmarkDetailViewModel(bookmark: bookmark, context: context)
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(viewModel.bookmark.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("URL")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(viewModel.bookmark.url)
                            .font(.body)
                            .foregroundColor(.blue)
                            .lineLimit(3)
                            .truncationMode(.tail)
                    }

                    if !viewModel.bookmark.description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(viewModel.bookmark.description)
                                .font(.body)
                                .lineLimit(nil)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Created")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(viewModel.bookmark.dateCreated.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    VStack(spacing: 12) {
                        Button(action: {
                            viewModel.openURL()
                        }) {
                            Label("Open in Safari", systemImage: "safari")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button(action: {
                            viewModel.copyURLToPasteboard()
                            showCopiedMessage = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showCopiedMessage = false
                            }
                        }) {
                            Label(
                                showCopiedMessage ? "Copied!" : "Copy URL",
                                systemImage: showCopiedMessage ? "checkmark" : "doc.on.doc"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        Button(action: { showEditSheet = true }) {
                            Label("Edit", systemImage: "pencil")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                            Label("Delete", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
            .navigationTitle("Bookmark")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showEditSheet) {
            BookmarkFormView(editing: viewModel.bookmark, onSave: {
                // Refresh from DB if needed
                showEditSheet = false
            })
            .environment(\.managedObjectContext, viewContext)
        }
        .alert("Delete Bookmark?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteBookmark()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func deleteBookmark() {
        isDeleting = true
        Task {
            do {
                try await viewModel.deleteBookmark()
                dismiss()
            } catch {
                isDeleting = false
            }
        }
    }
}

#Preview {
    BookmarkDetailView(
        bookmark: Bookmark(
            url: "https://www.apple.com",
            title: "Apple",
            description: "Apple's official website"
        )
    )
}

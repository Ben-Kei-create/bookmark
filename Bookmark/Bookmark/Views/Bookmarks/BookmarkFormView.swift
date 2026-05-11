import SwiftUI

struct BookmarkFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: BookmarkFormViewModel
    @State private var isSaving = false

    var onSave: () -> Void = {}

    init(editing bookmark: Bookmark? = nil, onSave: @escaping () -> Void = {}) {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        _viewModel = StateObject(
            wrappedValue: BookmarkFormViewModel(context: context, editing: bookmark)
        )
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("URL") {
                    TextField("Enter URL", text: $viewModel.url)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .onChange(of: viewModel.url) { _, _ in
                            viewModel.validateURL()
                        }

                    if let error = viewModel.urlError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                Section("Title") {
                    TextField("Enter title (or auto-fill from domain)", text: $viewModel.title)
                }

                Section("Description") {
                    TextEditor(text: $viewModel.description)
                        .frame(height: 100)
                }
            }
            .navigationTitle(viewModel.editingBookmark == nil ? "Add Bookmark" : "Edit Bookmark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBookmark()
                    }
                    .disabled(!viewModel.isFormValid || isSaving)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.formError != nil)) {
                Button("OK") { viewModel.formError = nil }
            } message: {
                Text(viewModel.formError ?? "An error occurred")
            }
        }
    }

    private func saveBookmark() {
        isSaving = true
        Task {
            do {
                try await viewModel.save()
                onSave()
                dismiss()
            } catch {
                viewModel.formError = error.localizedDescription
                isSaving = false
            }
        }
    }
}

#Preview {
    BookmarkFormView()
}

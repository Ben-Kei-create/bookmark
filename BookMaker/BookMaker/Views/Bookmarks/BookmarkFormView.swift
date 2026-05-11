import SwiftUI

struct BookmarkFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: BookmarkFormViewModel
    @FocusState private var focusedField: FormField?

    var onSave: (() -> Void)?

    init(editing entity: BookmarkEntity? = nil, onSave: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: BookmarkFormViewModel(editing: entity))
        self.onSave = onSave
    }

    enum FormField { case url, title, description }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    urlField
                } footer: {
                    if let error = viewModel.urlError {
                        Label(error, systemImage: "exclamationmark.circle")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                Section {
                    TextField(viewModel.titlePlaceholder, text: $viewModel.title)
                        .focused($focusedField, equals: .title)
                } footer: {
                    Text("Leave blank to use the site name automatically")
                        .font(.caption)
                }

                Section {
                    TextField("Notes or description (optional)", text: $viewModel.description, axis: .vertical)
                        .focused($focusedField, equals: .description)
                        .lineLimit(3...6)
                } footer: {
                    Text("Visible without opening the link")
                        .font(.caption)
                }
            }
            .navigationTitle(viewModel.editingEntity == nil ? "New Bookmark" : "Edit Bookmark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving {
                        ProgressView().controlSize(.small)
                    } else {
                        Button("Save") { save() }
                            .fontWeight(.semibold)
                            .disabled(!viewModel.isFormValid)
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.saveError != nil)) {
                Button("OK") { viewModel.saveError = nil }
            } message: {
                Text(viewModel.saveError ?? "")
            }
        }
    }

    // MARK: - URL Field

    private var urlField: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "link")
                    .foregroundColor(.secondary)
                    .frame(width: 20)

                TextField("https://example.com", text: $viewModel.url)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .url)
                    .onChange(of: viewModel.url) { _, _ in viewModel.validateURL() }
                    .submitLabel(.next)
                    .onSubmit { focusedField = .title }

                if !viewModel.url.isEmpty {
                    Button { viewModel.url = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button("Paste") { viewModel.pasteFromClipboard() }
                        .font(.callout)
                        .foregroundColor(.accentColor)
                }
            }
        }
    }

    // MARK: - Save

    private func save() {
        Task {
            do {
                try await viewModel.save(in: viewContext)
                onSave?()
                dismiss()
            } catch {
                viewModel.saveError = error.localizedDescription
            }
        }
    }
}

#Preview {
    BookmarkFormView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

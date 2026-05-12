import SwiftUI
import CoreData

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
            ZStack {
                AppTheme.Colors.paleBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        urlField
                        titleField
                        descriptionField
                        Spacer()
                    }
                    .padding(AppTheme.Spacing.lg)
                }
            }
            .navigationTitle(viewModel.editingEntity == nil ? AppStrings.newBookmark : AppStrings.editBookmark)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppStrings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving {
                        ProgressView().controlSize(.small)
                    } else {
                        Button(AppStrings.save) { save() }
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.Colors.primaryBlue)
                            .disabled(!viewModel.isFormValid)
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(AppStrings.done) { focusedField = nil }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.saveError != nil)) {
                Button("OK") { viewModel.saveError = nil }
            } message: {
                Text(viewModel.saveError ?? "")
            }
        }
    }

    private var urlField: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Label(AppStrings.websiteURL, systemImage: "link")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.Colors.textPrimary)

            HStack(spacing: AppTheme.Spacing.md) {
                TextField("https://example.com", text: $viewModel.url)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .url)
                    .onChange(of: viewModel.url) { _, _ in viewModel.validateURL() }
                    .submitLabel(.next)
                    .onSubmit { focusedField = .title }
                    .padding(AppTheme.Spacing.md)
                    .background(Color.white)
                    .cornerRadius(AppTheme.Radius.md)

                if !viewModel.url.isEmpty {
                    Button { viewModel.url = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(AppStrings.paste) { viewModel.pasteFromClipboard() }
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.Colors.primaryBlue)
                }
            }

            if let error = viewModel.urlError {
                Label(error, systemImage: "exclamationmark.circle")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, AppTheme.Spacing.xs)
            }
        }
        .appCardStyle()
    }

    private var titleField: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Label(AppStrings.title, systemImage: "heading")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.Colors.textPrimary)

            TextField(AppStrings.titlePlaceholder, text: $viewModel.title)
                .focused($focusedField, equals: .title)
                .padding(AppTheme.Spacing.md)
                .background(Color.white)
                .cornerRadius(AppTheme.Radius.md)
                .submitLabel(.next)
                .onSubmit { focusedField = .description }

            Text(AppStrings.leaveBlankForAutoFill)
                .font(.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .padding(.top, AppTheme.Spacing.xs)
        }
        .appCardStyle()
    }

    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Label(AppStrings.notes, systemImage: "text.alignleft")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.Colors.textPrimary)

            TextField(AppStrings.notesPlaceholder, text: $viewModel.description, axis: .vertical)
                .focused($focusedField, equals: .description)
                .lineLimit(3...6)
                .padding(AppTheme.Spacing.md)
                .background(Color.white)
                .cornerRadius(AppTheme.Radius.md)

            Text(AppStrings.visibleWithoutOpening)
                .font(.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .padding(.top, AppTheme.Spacing.xs)
        }
        .appCardStyle()
    }

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

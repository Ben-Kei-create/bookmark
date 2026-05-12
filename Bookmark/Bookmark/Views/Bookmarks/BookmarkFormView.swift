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

    enum FormField { case url, title, notes, tagInput }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.paleBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.md) {
                        urlCard
                        titleCard
                        folderCard
                        tagsCard
                        notesCard
                        PrivacyInfoCard()
                        Spacer().frame(height: AppTheme.Spacing.xl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.md)
                }
            }
            .navigationTitle(viewModel.editingEntity == nil ? AppStrings.newBookmark : AppStrings.editBookmark)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppStrings.cancel) { dismiss() }
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving {
                        ProgressView().controlSize(.small)
                    } else {
                        Button(AppStrings.save) { save() }
                            .fontWeight(.semibold)
                            .foregroundColor(
                                viewModel.isFormValid
                                    ? AppTheme.Colors.primaryBlue
                                    : AppTheme.Colors.textSecondary
                            )
                            .disabled(!viewModel.isFormValid)
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(AppStrings.done) { focusedField = nil }
                        .foregroundColor(AppTheme.Colors.primaryBlue)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.saveError != nil)) {
                Button("OK") { viewModel.saveError = nil }
            } message: {
                Text(viewModel.saveError ?? "")
            }
        }
    }

    // MARK: - URL Card

    private var urlCard: some View {
        FormCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                SectionLabel(text: AppStrings.websiteURL, icon: "link")

                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "link")
                        .foregroundColor(AppTheme.Colors.primaryBlue)
                        .frame(width: 20)

                    TextField("https://example.com", text: $viewModel.url)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .url)
                        .onChange(of: viewModel.url) { _, _ in viewModel.validateURL() }
                        .submitLabel(.next)
                        .onSubmit { focusedField = .title }

                    Spacer()

                    if !viewModel.url.isEmpty {
                        Button { viewModel.url = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(AppStrings.paste) { viewModel.pasteFromClipboard() }
                            .font(AppTheme.Typography.footnote(weight: .semibold))
                            .foregroundColor(AppTheme.Colors.primaryBlue)
                    }
                }
                .appInputStyle()

                if let error = viewModel.urlError {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill")
                        Text(error)
                    }
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.Colors.errorRed)
                }
            }
        }
    }

    // MARK: - Title Card

    private var titleCard: some View {
        FormCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                SectionLabel(text: AppStrings.title, icon: "textformat")

                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "character.cursor.ibeam")
                        .foregroundColor(AppTheme.Colors.primaryBlue)
                        .frame(width: 20)

                    TextField(viewModel.titlePlaceholder, text: $viewModel.title)
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .notes }
                }
                .appInputStyle()

                Text(AppStrings.leaveBlankForAutoFill)
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
    }

    // MARK: - Folder Card

    private var folderCard: some View {
        FormCard {
            HStack(spacing: AppTheme.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.Colors.lightBlue)
                        .frame(width: 32, height: 32)
                    Image(systemName: "folder.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.primaryBlue)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("Folder")
                        .font(AppTheme.Typography.footnote(weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    Text(viewModel.folderName.isEmpty ? "Unsorted" : viewModel.folderName)
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
    }

    // MARK: - Tags Card

    private var tagsCard: some View {
        FormCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                SectionLabel(text: "Tags", icon: "tag.fill")

                if !viewModel.tags.isEmpty {
                    FlowLayout(spacing: AppTheme.Spacing.sm) {
                        ForEach(viewModel.tags, id: \.self) { tag in
                            TagChip(tag: tag) { viewModel.removeTag(tag) }
                        }
                    }
                }

                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "tag")
                        .foregroundColor(AppTheme.Colors.primaryBlue)
                        .frame(width: 20)

                    TextField("Add tags…", text: $viewModel.tagInput)
                        .focused($focusedField, equals: .tagInput)
                        .submitLabel(.done)
                        .onSubmit { viewModel.addTag() }

                    if !viewModel.tagInput.isEmpty {
                        Button("Add") { viewModel.addTag() }
                            .font(AppTheme.Typography.footnote(weight: .semibold))
                            .foregroundColor(AppTheme.Colors.primaryBlue)
                    }
                }
                .appInputStyle()

                Text("Press return or tap Add to save a tag.")
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
    }

    // MARK: - Notes Card

    private var notesCard: some View {
        FormCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                SectionLabel(text: AppStrings.notes, icon: "note.text")

                HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "text.alignleft")
                        .foregroundColor(AppTheme.Colors.primaryBlue)
                        .frame(width: 20)
                        .padding(.top, 2)

                    TextField(AppStrings.notesPlaceholder, text: $viewModel.description, axis: .vertical)
                        .focused($focusedField, equals: .notes)
                        .lineLimit(3...7)
                }
                .appInputStyle()

                Text(AppStrings.visibleWithoutOpening)
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.Colors.textSecondary)
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

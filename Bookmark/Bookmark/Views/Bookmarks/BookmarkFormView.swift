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

    enum FormField { case url, title, description, tagInput }

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
                        privacyCard
                        Spacer().frame(height: AppTheme.Spacing.xxl)
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
                        .fontWeight(.medium)
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
                FormSectionLabel(text: AppStrings.websiteURL, icon: "link")

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

                    if !viewModel.url.isEmpty {
                        Button {
                            viewModel.url = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .font(.system(size: 16))
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(AppStrings.paste) {
                            viewModel.pasteFromClipboard()
                        }
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.Colors.primaryBlue)
                    }
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.paleBackground)
                .cornerRadius(AppTheme.Radius.sm)

                if let error = viewModel.urlError {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.caption)
                        Text(error)
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }

    // MARK: - Title Card

    private var titleCard: some View {
        FormCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                FormSectionLabel(text: AppStrings.title, icon: "textformat")

                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "character.cursor.ibeam")
                        .foregroundColor(AppTheme.Colors.primaryBlue)
                        .frame(width: 20)

                    TextField(viewModel.titlePlaceholder, text: $viewModel.title)
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .description }
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.paleBackground)
                .cornerRadius(AppTheme.Radius.sm)

                Text(AppStrings.leaveBlankForAutoFill)
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
    }

    // MARK: - Folder Card

    private var folderCard: some View {
        FormCard {
            HStack(spacing: AppTheme.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                        .fill(AppTheme.Colors.lightBlue)
                        .frame(width: 32, height: 32)
                    Image(systemName: "folder.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.primaryBlue)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Folder")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Text("Unsorted")
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
    }

    // MARK: - Tags Card

    private var tagsCard: some View {
        FormCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                FormSectionLabel(text: "Tags", icon: "tag.fill")

                if !viewModel.tags.isEmpty {
                    FlowLayout(spacing: AppTheme.Spacing.sm) {
                        ForEach(viewModel.tags, id: \.self) { tag in
                            TagChipView(tag: tag) {
                                viewModel.removeTag(tag)
                            }
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
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.paleBackground)
                .cornerRadius(AppTheme.Radius.sm)
            }
        }
    }

    // MARK: - Notes Card

    private var notesCard: some View {
        FormCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                FormSectionLabel(text: AppStrings.notes, icon: "note.text")

                HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "text.alignleft")
                        .foregroundColor(AppTheme.Colors.primaryBlue)
                        .frame(width: 20)
                        .padding(.top, 2)

                    TextField(AppStrings.notesPlaceholder, text: $viewModel.description, axis: .vertical)
                        .focused($focusedField, equals: .description)
                        .lineLimit(3...6)
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.paleBackground)
                .cornerRadius(AppTheme.Radius.sm)

                Text(AppStrings.visibleWithoutOpening)
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
    }

    // MARK: - Privacy Card

    private var privacyCard: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.lightBlue)
                    .frame(width: 36, height: 36)
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.primaryBlue)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Private & Secure")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("Your bookmarks stay on your device.")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.lightBlue.opacity(0.5))
        .cornerRadius(AppTheme.Radius.md)
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

// MARK: - Reusable Form Components

struct FormCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppTheme.Spacing.md)
            .background(Color.white)
            .cornerRadius(AppTheme.Radius.md)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct FormSectionLabel: View {
    let text: String
    let icon: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(AppTheme.Colors.textPrimary)
    }
}

struct TagChipView: View {
    let tag: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.Colors.primaryBlue)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryBlue)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(AppTheme.Colors.lightBlue)
        .cornerRadius(12)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.size.height }.max() ?? 0 }.reduce(0) { $0 + $1 + spacing } - spacing
        return CGSize(width: proposal.width ?? 0, height: max(height, 0))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.size.height }.max() ?? 0
            for item in row {
                item.subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(item.size))
                x += item.size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private struct SubviewItem {
        let subview: LayoutSubview
        let size: CGSize
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[SubviewItem]] {
        let maxWidth = proposal.width ?? 0
        var rows: [[SubviewItem]] = [[]]
        var rowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth && !rows[rows.count - 1].isEmpty {
                rows.append([])
                rowWidth = 0
            }
            rows[rows.count - 1].append(SubviewItem(subview: subview, size: size))
            rowWidth += size.width + spacing
        }
        return rows
    }
}

#Preview {
    BookmarkFormView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

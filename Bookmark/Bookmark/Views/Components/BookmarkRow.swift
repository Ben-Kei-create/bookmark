import SwiftUI
import CoreData

struct BookmarkRow: View {
    let entity: BookmarkEntity
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isFavorited: Bool

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }()

    init(entity: BookmarkEntity) {
        self.entity = entity
        self._isFavorited = State(initialValue: entity.isFavorite)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Top row: icon + title/domain + star
            HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
                DomainIconView(domain: entity.domain, size: 46)

                VStack(alignment: .leading, spacing: 3) {
                    Text(entity.displayTitle)
                        .font(AppTheme.Typography.subheadline(weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.Colors.primaryBlue)
                        Text(entity.domain)
                            .font(AppTheme.Typography.caption())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        try? entity.toggleFavorite(in: viewContext)
                        isFavorited.toggle()
                    }
                } label: {
                    Image(systemName: isFavorited ? "star.fill" : "star")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isFavorited ? .yellow : AppTheme.Colors.textSecondary)
                        .scaleEffect(isFavorited ? 1.1 : 1.0)
                }
                .buttonStyle(.plain)
            }

            // Description preview
            if !entity.descriptionText.isEmpty {
                Text(entity.descriptionText)
                    .font(AppTheme.Typography.footnote())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(2)
                    .padding(.leading, 62)
            }

            // Tags + date footer
            HStack(spacing: AppTheme.Spacing.sm) {
                // Tag chips (max 2)
                let tags = entity.tagList.prefix(2)
                if !tags.isEmpty {
                    ForEach(Array(tags), id: \.self) { tag in
                        TagChip(tag: tag)
                    }
                    if entity.tagList.count > 2 {
                        Text("+\(entity.tagList.count - 2)")
                            .font(AppTheme.Typography.caption())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }

                Spacer()

                Text(Self.dateFormatter.string(from: entity.dateCreated))
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(.leading, 62)
        }
        .padding(AppTheme.Spacing.md)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
        .shadow(color: Color.black.opacity(0.055), radius: 10, x: 0, y: 3)
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.md) {
        BookmarkRow(entity: {
            let ctx = PersistenceController.preview.container.viewContext
            return (try! ctx.fetch(BookmarkEntity.fetchRequest())).first!
        }())
    }
    .padding(AppTheme.Spacing.lg)
    .background(AppTheme.Colors.paleBackground)
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

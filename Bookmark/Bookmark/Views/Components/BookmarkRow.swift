import SwiftUI
import CoreData

struct BookmarkRow: View {
    let entity: BookmarkEntity
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isFavorited = false

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            domainIcon
            content
            starButton
        }
        .padding(AppTheme.Spacing.md)
        .appCardStyle()
        .onAppear { isFavorited = entity.isFavorite }
    }

    private var domainIcon: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    AppTheme.Colors.primaryBlue,
                    AppTheme.Colors.deepBlue
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))

            Text(domainInitial)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }

    private var domainInitial: String {
        let domain = URLValidator.extractDomain(from: entity.url)
        return String(domain.prefix(1)).uppercased()
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entity.title)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .foregroundColor(AppTheme.Colors.textPrimary)

            if !entity.descriptionText.isEmpty {
                Text(entity.descriptionText)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(1)
            }

            HStack(spacing: 4) {
                Image(systemName: "link")
                    .font(.caption2)
                    .foregroundColor(AppTheme.Colors.primaryBlue)
                Text(URLValidator.extractDomain(from: entity.url))
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(1)
            }
        }

        Spacer()
    }

    private var starButton: some View {
        Button {
            try? entity.toggleFavorite(in: viewContext)
            isFavorited.toggle()
        } label: {
            Image(systemName: isFavorited ? "star.fill" : "star")
                .font(.system(size: 16))
                .foregroundColor(isFavorited ? .yellow : AppTheme.Colors.textSecondary)
        }
        .buttonStyle(.plain)
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

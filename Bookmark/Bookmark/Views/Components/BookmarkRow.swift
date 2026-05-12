import SwiftUI
import CoreData

struct BookmarkRow: View {
    let entity: BookmarkEntity
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isFavorited = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.md) {
                domainIcon

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(entity.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    HStack(spacing: AppTheme.Spacing.xs) {
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

                starButton
            }

            if !entity.descriptionText.isEmpty {
                Text(entity.descriptionText)
                    .font(.callout)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(2)
            }

            metadataFooter
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
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))

            Text(domainInitial)
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(.white)
        }
    }

    private var domainInitial: String {
        let domain = URLValidator.extractDomain(from: entity.url)
        return String(domain.prefix(1)).uppercased()
    }

    private var starButton: some View {
        Button {
            try? entity.toggleFavorite(in: viewContext)
            isFavorited.toggle()
        } label: {
            Image(systemName: isFavorited ? "star.fill" : "star")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(isFavorited ? .yellow : AppTheme.Colors.textSecondary)
        }
        .buttonStyle(.plain)
    }

    private var metadataFooter: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Label(
                formattedDate,
                systemImage: "calendar"
            )
            .font(.caption2)
            .foregroundColor(AppTheme.Colors.textSecondary)

            Spacer()

            if entity.isFavorite {
                Label("Favorited", systemImage: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.yellow)
            }
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: entity.dateCreated)
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

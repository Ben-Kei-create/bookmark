import SwiftUI
import CoreData

struct BookmarkRow: View {
    let entity: BookmarkEntity

    var body: some View {
        HStack(spacing: 14) {
            domainIcon
            content
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
    }

    private var domainIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(iconBackgroundColor)
                .frame(width: 42, height: 42)
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(iconColor)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entity.title)
                .font(.headline)
                .lineLimit(1)
                .foregroundColor(.primary)

            if !entity.descriptionText.isEmpty {
                Text(entity.descriptionText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Label(URLValidator.extractDomain(from: entity.url), systemImage: "link")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }

    // MARK: - Dynamic icon based on domain

    private var domain: String {
        URLValidator.extractDomain(from: entity.url).lowercased()
    }

    private var iconName: String {
        if domain.contains("github") { return "chevron.left.forwardslash.chevron.right" }
        if domain.contains("youtube") || domain.contains("youtu.be") { return "play.rectangle.fill" }
        if domain.contains("twitter") || domain.contains("x.com") { return "bird" }
        if domain.contains("reddit") { return "bubble.left.and.bubble.right" }
        if domain.contains("apple") || domain.contains("developer.apple") { return "apple.logo" }
        if domain.contains("medium") || domain.contains("blog") { return "text.alignleft" }
        if domain.contains("amazon") || domain.contains("shop") { return "cart" }
        if domain.contains("news") || domain.contains("nikkei") || domain.contains("cnn") { return "newspaper" }
        return "globe"
    }

    private var iconBackgroundColor: Color {
        if domain.contains("github") { return Color(.systemGray5) }
        if domain.contains("youtube") { return Color.red.opacity(0.12) }
        if domain.contains("twitter") || domain.contains("x.com") { return Color.blue.opacity(0.12) }
        if domain.contains("apple") { return Color(.systemGray5) }
        return Color.accentColor.opacity(0.1)
    }

    private var iconColor: Color {
        if domain.contains("youtube") { return .red }
        if domain.contains("twitter") || domain.contains("x.com") { return .blue }
        if domain.contains("github") { return Color(.label) }
        if domain.contains("apple") { return Color(.label) }
        return .accentColor
    }
}

#Preview {
    VStack(spacing: 8) {
        BookmarkRow(entity: {
            let ctx = PersistenceController.preview.container.viewContext
            return (try! ctx.fetch(BookmarkEntity.fetchRequest())).first!
        }())
    }
    .padding()
    .background(Color(.systemGroupedBackground))
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

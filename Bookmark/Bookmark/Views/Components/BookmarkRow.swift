import SwiftUI

struct BookmarkRow: View {
    let bookmark: Bookmark

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bookmark.title)
                        .font(.headline)
                        .lineLimit(1)

                    if !bookmark.description.isEmpty {
                        Text(bookmark.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }

                    Text(URLValidator.extractDomain(from: bookmark.url))
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    BookmarkRow(
        bookmark: Bookmark(
            url: "https://www.apple.com",
            title: "Apple",
            description: "Apple's official website"
        )
    )
}

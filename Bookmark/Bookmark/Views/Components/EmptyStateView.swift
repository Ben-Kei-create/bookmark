import SwiftUI

struct EmptyStateView: View {
    var action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.12))
                        .frame(width: 90, height: 90)
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(Color.accentColor)
                }

                VStack(spacing: 6) {
                    Text("No Bookmarks")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Save your favorite sites to access them anytime.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }

            Spacer().frame(height: 32)

            Button(action: action) {
                Label("Add Your First Bookmark", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: 280)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView {}
}

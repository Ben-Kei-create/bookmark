import SwiftUI

struct EmptyStateView: View {
    var action: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            VStack(spacing: 8) {
                Text("No Bookmarks Yet")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Start adding your favorite links to keep them organized")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: action) {
                Label("Add Bookmark", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    EmptyStateView(action: {})
}

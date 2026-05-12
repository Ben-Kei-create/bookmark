import SwiftUI

struct EmptyStateView: View {
    var action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: AppTheme.Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppTheme.Colors.primaryBlue.opacity(0.15),
                                    AppTheme.Colors.deepBlue.opacity(0.08)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)

                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 44))
                        .foregroundColor(AppTheme.Colors.primaryBlue)
                }

                VStack(spacing: AppTheme.Spacing.sm) {
                    Text(AppStrings.noBookmarks)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Text(AppStrings.noBookmarksDescription)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.Spacing.xl)
                }
            }

            Spacer().frame(height: AppTheme.Spacing.xxl)

            Button(action: action) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(AppStrings.addYourFirstBookmark)
                }
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: 280)
                .padding(.vertical, AppTheme.Spacing.md)
            }
            .appPrimaryButtonStyle()
            .buttonStyle(.plain)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView {}
        .background(AppTheme.Colors.paleBackground)
}

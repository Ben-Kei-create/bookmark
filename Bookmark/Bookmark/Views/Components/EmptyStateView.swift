import SwiftUI

struct EmptyStateView: View {
    var action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: AppTheme.Spacing.lg)

            VStack(spacing: AppTheme.Spacing.xl) {
                illustration

                headlineAndDescription

                Spacer().frame(height: AppTheme.Spacing.lg)

                primaryButton
                    .padding(.horizontal, AppTheme.Spacing.lg)

                tipMessage
                    .padding(.horizontal, AppTheme.Spacing.lg)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var illustration: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppTheme.Colors.lightBlue.opacity(0.6),
                                AppTheme.Colors.primaryBlue.opacity(0.15)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "bookmark.fill")
                    .font(.system(size: 56))
                    .foregroundColor(AppTheme.Colors.primaryBlue)
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.bottom, AppTheme.Spacing.lg)

            decorativeElements
        }
    }

    private var decorativeElements: some View {
        HStack(spacing: AppTheme.Spacing.lg) {
            Circle()
                .fill(AppTheme.Colors.lightBlue.opacity(0.4))
                .frame(width: 8, height: 8)

            Spacer()

            Circle()
                .fill(AppTheme.Colors.primaryBlue.opacity(0.3))
                .frame(width: 6, height: 6)
        }
        .padding(.horizontal, AppTheme.Spacing.xxl)
        .frame(height: 12)
    }

    private var headlineAndDescription: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            VStack(spacing: 2) {
                Text("Your bookmarks,")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(AppTheme.Colors.textPrimary)

                HStack(spacing: 0) {
                    Text("always within reach")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(AppTheme.Colors.primaryBlue)

                    Text(".")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(AppTheme.Colors.primaryBlue)
                }
            }

            Text("Save your favorite sites, organize them with ease, and access them anytime.")
                .font(.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(1.5)
        }
    }

    private var primaryButton: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                Text(AppStrings.addYourFirstBookmark)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundColor(.white)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppTheme.Colors.primaryBlue,
                        AppTheme.Colors.deepBlue
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(27)
            .shadow(
                color: AppTheme.Colors.primaryBlue.opacity(0.3),
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .buttonStyle(.plain)
    }

    private var tipMessage: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "lightbulb.fill")
                .font(.caption)
                .foregroundColor(AppTheme.Colors.primaryBlue)

            Text("Save and organize your links in one secure place.")
                .font(.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)

            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.lightBlue.opacity(0.5))
        .cornerRadius(AppTheme.Radius.md)
    }
}

#Preview {
    EmptyStateView {}
        .background(AppTheme.Colors.paleBackground)
}
